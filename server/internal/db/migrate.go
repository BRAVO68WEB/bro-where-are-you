package db

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

const migrationSQL = `
CREATE EXTENSION IF NOT EXISTS postgis;

-- Device Code Auth
CREATE TABLE IF NOT EXISTS device_codes (
    device_code   TEXT PRIMARY KEY,
    device_id     UUID NOT NULL DEFAULT gen_random_uuid(),
    device_name   TEXT NOT NULL,
    platform      TEXT NOT NULL,
    user_id       TEXT,
    status        TEXT NOT NULL DEFAULT 'pending',
    device_token  TEXT,
    created_at    TIMESTAMPTZ DEFAULT now(),
    expires_at    TIMESTAMPTZ DEFAULT now() + interval '10 minutes',
    activated_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_device_codes_status ON device_codes (status);

-- Devices
CREATE TABLE IF NOT EXISTS devices (
    id          UUID PRIMARY KEY,
    user_id     TEXT,
    name        TEXT NOT NULL,
    platform    TEXT NOT NULL,
    fcm_token   TEXT,
    last_seen   TIMESTAMPTZ DEFAULT now(),
    active      BOOLEAN DEFAULT true,
    created_at  TIMESTAMPTZ DEFAULT now()
);

-- Journeys
CREATE TABLE IF NOT EXISTS journeys (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id       TEXT NOT NULL,
    user_id         TEXT,
    label           TEXT,
    started_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    ended_at        TIMESTAMPTZ,
    total_distance_m DOUBLE PRECISION DEFAULT 0,
    source          TEXT NOT NULL DEFAULT 'phone',
    transport_mode  TEXT,
    start_place     TEXT,
    end_place       TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Location points (partitioned by month)
CREATE TABLE IF NOT EXISTS location_points (
    id          BIGSERIAL,
    journey_id  UUID NOT NULL REFERENCES journeys(id) ON DELETE CASCADE,
    device_id   TEXT NOT NULL,
    geog        GEOGRAPHY(POINT, 4326) NOT NULL,
    accuracy    FLOAT,
    speed       FLOAT,
    altitude    FLOAT,
    heading     FLOAT,
    source      TEXT NOT NULL DEFAULT 'phone',
    recorded_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id, recorded_at)
) PARTITION BY RANGE (recorded_at);

-- Saved Locations
CREATE TABLE IF NOT EXISTS saved_locations (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id   TEXT NOT NULL,
    name        TEXT NOT NULL,
    geog        GEOGRAPHY(POINT, 4326) NOT NULL,
    radius_m    FLOAT DEFAULT 100,
    created_at  TIMESTAMPTZ DEFAULT now()
);

-- Share Links
CREATE TABLE IF NOT EXISTS share_links (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journey_id  UUID REFERENCES journeys(id) ON DELETE CASCADE,
    device_id   TEXT NOT NULL,
    expires_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ DEFAULT now()
);

-- Indexes
DO $$
BEGIN
    CREATE INDEX IF NOT EXISTS idx_lp_geog ON location_points USING GIST (geog);
EXCEPTION WHEN others THEN NULL;
END $$;

DO $$
BEGIN
    CREATE INDEX IF NOT EXISTS idx_lp_journey ON location_points (journey_id, recorded_at);
EXCEPTION WHEN others THEN NULL;
END $$;

CREATE INDEX IF NOT EXISTS idx_journeys_device ON journeys (device_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_saved_locations_device ON saved_locations (device_id);
CREATE INDEX IF NOT EXISTS idx_saved_locations_geog ON saved_locations USING GIST (geog);
`

// RunMigrations applies the schema. Safe to run multiple times.
func RunMigrations(ctx context.Context, pool *pgxpool.Pool) error {
	_, err := pool.Exec(ctx, migrationSQL)
	if err != nil {
		return fmt.Errorf("run migrations: %w", err)
	}

	// Create current + next month partition
	if err := ensurePartitions(ctx, pool); err != nil {
		return fmt.Errorf("ensure partitions: %w", err)
	}

	return nil
}

func ensurePartitions(ctx context.Context, pool *pgxpool.Pool) error {
	// Create partitions for current month and next 2 months
	for i := 0; i < 3; i++ {
		start := firstOfMonth(i)
		end := firstOfMonth(i + 1)
		partName := fmt.Sprintf("location_points_%s", start.Format("2006_01"))

		sql := fmt.Sprintf(
			`CREATE TABLE IF NOT EXISTS %s PARTITION OF location_points
			 FOR VALUES FROM ('%s') TO ('%s')`,
			partName,
			start.Format("2006-01-02"),
			end.Format("2006-01-02"),
		)
		if _, err := pool.Exec(ctx, sql); err != nil {
			return fmt.Errorf("create partition %s: %w", partName, err)
		}
	}

	// Drop partitions older than 3 months
	dropBefore := firstOfMonth(-3)
	rows, err := pool.Query(ctx,
		`SELECT tablename FROM pg_tables
		 WHERE schemaname = 'public'
		 AND tablename LIKE 'location_points_%'
		 AND tablename < $1`,
		fmt.Sprintf("location_points_%s", dropBefore.Format("2006_01")),
	)
	if err != nil {
		return fmt.Errorf("query old partitions: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var name string
		if err := rows.Scan(&name); err != nil {
			return err
		}
		if _, err := pool.Exec(ctx, fmt.Sprintf("DROP TABLE IF EXISTS %s CASCADE", name)); err != nil {
			return fmt.Errorf("drop partition %s: %w", name, err)
		}
	}

	return nil
}

func firstOfMonth(offset int) time.Time {
	now := time.Now().UTC()
	year, month, _ := now.Date()
	month = time.Month(int(month) + offset)
	for month > 12 {
		year++
		month -= 12
	}
	for month < 1 {
		year--
		month += 12
	}
	return time.Date(year, month, 1, 0, 0, 0, 0, time.UTC)
}
