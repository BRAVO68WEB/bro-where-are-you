package db

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"bwhere/internal/geocode"
	pb "bwhere/pb/location/v1"
)

type DB struct {
	pool *pgxpool.Pool
}

type Journey struct {
	ID              string
	DeviceID        string
	Label           string
	StartedAt       time.Time
	EndedAt         *time.Time
	TotalDistanceM  float64
	PointCount      int32
	Source          string
	TransportMode   string
	StartPlace      string
	EndPlace        string
}

type LocationPoint struct {
	JourneyID  string
	DeviceID   string
	Latitude   float64
	Longitude  float64
	Accuracy   float32
	Speed      float32
	Altitude   float32
	Heading    float32
	Source     string
	RecordedAt time.Time
}

func New(ctx context.Context, connStr string) (*DB, error) {
	cfg, err := pgxpool.ParseConfig(connStr)
	if err != nil {
		return nil, fmt.Errorf("parse conn string: %w", err)
	}
	cfg.MaxConns = 10
	cfg.MinConns = 2

	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("create pool: %w", err)
	}
	if err := pool.Ping(ctx); err != nil {
		return nil, fmt.Errorf("ping: %w", err)
	}
	return &DB{pool: pool}, nil
}

func (d *DB) Close() {
	d.pool.Close()
}

func (d *DB) Pool() *pgxpool.Pool {
	return d.pool
}

func (d *DB) StartJourney(ctx context.Context, deviceID, label string) (*Journey, error) {
	row := d.pool.QueryRow(ctx,
		`INSERT INTO journeys (device_id, label) VALUES ($1, $2)
		 RETURNING id, device_id, label, started_at, source`,
		deviceID, label,
	)
	var j Journey
	if err := row.Scan(&j.ID, &j.DeviceID, &j.Label, &j.StartedAt, &j.Source); err != nil {
		return nil, fmt.Errorf("insert journey: %w", err)
	}
	return &j, nil
}

func (d *DB) EndJourney(ctx context.Context, journeyID string) (*Journey, error) {
	row := d.pool.QueryRow(ctx,
		`UPDATE journeys SET ended_at = now() WHERE id = $1
		 RETURNING id, device_id, label, started_at, ended_at, total_distance_m, source`,
		journeyID,
	)
	var j Journey
	if err := row.Scan(&j.ID, &j.DeviceID, &j.Label, &j.StartedAt, &j.EndedAt, &j.TotalDistanceM, &j.Source); err != nil {
		return nil, fmt.Errorf("end journey: %w", err)
	}

	// Compute total distance from stored points
	distRow := d.pool.QueryRow(ctx,
		`SELECT COALESCE(ST_Length(ST_MakeLine(geog::geometry ORDER BY recorded_at)::geography), 0)
		 FROM location_points WHERE journey_id = $1`,
		journeyID,
	)
	if err := distRow.Scan(&j.TotalDistanceM); err != nil {
		return nil, fmt.Errorf("compute distance: %w", err)
	}

	// Update the journey with computed distance
	_, err := d.pool.Exec(ctx,
		`UPDATE journeys SET total_distance_m = $1 WHERE id = $2`,
		j.TotalDistanceM, journeyID,
	)
	if err != nil {
		return nil, fmt.Errorf("update distance: %w", err)
	}

	// Get point count and average speed
	var avgSpeed float64
	countRow := d.pool.QueryRow(ctx,
		`SELECT COUNT(*), COALESCE(AVG(speed), 0) FROM location_points WHERE journey_id = $1`,
		journeyID,
	)
	if err := countRow.Scan(&j.PointCount, &avgSpeed); err != nil {
		return nil, fmt.Errorf("count points: %w", err)
	}

	// Classify transport mode
	transportMode := geocode.ClassifyTransportMode(avgSpeed)

	// Get start and end point coordinates for geocoding
	var startLat, startLng, endLat, endLng float64
	startRow := d.pool.QueryRow(ctx,
		`SELECT ST_Y(geog::geometry), ST_X(geog::geometry)
		 FROM location_points WHERE journey_id = $1
		 ORDER BY recorded_at ASC LIMIT 1`, journeyID,
	)
	_ = startRow.Scan(&startLat, &startLng)

	endRow := d.pool.QueryRow(ctx,
		`SELECT ST_Y(geog::geometry), ST_X(geog::geometry)
		 FROM location_points WHERE journey_id = $1
		 ORDER BY recorded_at DESC LIMIT 1`, journeyID,
	)
	_ = endRow.Scan(&endLat, &endLng)

	// Geocode start and end places (non-blocking, best effort)
	startPlace, endPlace := "", ""
	if startLat != 0 {
		if name, err := geocode.ReverseGeocode(startLat, startLng); err == nil {
			startPlace = name
		} else {
			slog.Warn("geocode start failed", "err", err)
		}
	}
	if endLat != 0 {
		if name, err := geocode.ReverseGeocode(endLat, endLng); err == nil {
			endPlace = name
		} else {
			slog.Warn("geocode end failed", "err", err)
		}
	}

	// Update journey with computed fields
	_, updateErr := d.pool.Exec(ctx,
		`UPDATE journeys SET
		   total_distance_m = $1,
		   transport_mode = $2,
		   start_place = $3,
		   end_place = $4
		 WHERE id = $5`,
		j.TotalDistanceM, transportMode, startPlace, endPlace, journeyID,
	)
	if updateErr != nil {
		return nil, fmt.Errorf("update journey: %w", updateErr)
	}

	j.TransportMode = transportMode
	j.StartPlace = startPlace
	j.EndPlace = endPlace

	return &j, nil
}

func (d *DB) GetJourneys(ctx context.Context, deviceID string, limit, offset int32) ([]*Journey, int32, error) {
	// Get total count
	var total int32
	err := d.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM journeys WHERE device_id = $1`, deviceID,
	).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("count journeys: %w", err)
	}

	// Get page
	rows, err := d.pool.Query(ctx,
		`SELECT id, device_id, label, started_at, ended_at, total_distance_m, source
		 FROM journeys WHERE device_id = $1
		 ORDER BY started_at DESC LIMIT $2 OFFSET $3`,
		deviceID, limit, offset,
	)
	if err != nil {
		return nil, 0, fmt.Errorf("query journeys: %w", err)
	}
	defer rows.Close()

	var journeys []*Journey
	for rows.Next() {
		var j Journey
		if err := rows.Scan(&j.ID, &j.DeviceID, &j.Label, &j.StartedAt, &j.EndedAt, &j.TotalDistanceM, &j.Source); err != nil {
			return nil, 0, fmt.Errorf("scan journey: %w", err)
		}
		journeys = append(journeys, &j)
	}
	return journeys, total, nil
}

// BulkInsertLocations inserts a batch of location points using batched INSERT.
func (d *DB) BulkInsertLocations(ctx context.Context, points []LocationPoint) error {
	if len(points) == 0 {
		return nil
	}

	batch := &pgx.Batch{}
	for _, p := range points {
		batch.Queue(
			`INSERT INTO location_points (journey_id, device_id, geog, accuracy, speed, altitude, heading, source, recorded_at)
			 VALUES ($1, $2, ST_SetSRID(ST_MakePoint($3, $4), 4326)::geography, $5, $6, $7, $8, $9, $10)`,
			p.JourneyID, p.DeviceID, p.Longitude, p.Latitude,
			p.Accuracy, p.Speed, p.Altitude, p.Heading, p.Source, p.RecordedAt,
		)
	}

	br := d.pool.SendBatch(ctx, batch)
	defer func() { _ = br.Close() }()

	for i := 0; i < batch.Len(); i++ {
		if _, err := br.Exec(); err != nil {
			return fmt.Errorf("insert point %d: %w", i, err)
		}
	}
	return nil
}

// ============================================================
// Journey Points
// ============================================================

func (d *DB) GetJourneyPoints(ctx context.Context, journeyID string) ([]LocationPoint, error) {
	rows, err := d.pool.Query(ctx,
		`SELECT ST_Y(geog::geometry), ST_X(geog::geometry), accuracy, speed, altitude, heading, recorded_at
		 FROM location_points WHERE journey_id = $1 ORDER BY recorded_at ASC`, journeyID,
	)
	if err != nil {
		return nil, fmt.Errorf("query points: %w", err)
	}
	defer rows.Close()

	var points []LocationPoint
	for rows.Next() {
		var p LocationPoint
		p.JourneyID = journeyID
		if err := rows.Scan(&p.Latitude, &p.Longitude, &p.Accuracy, &p.Speed, &p.Altitude, &p.Heading, &p.RecordedAt); err != nil {
			return nil, fmt.Errorf("scan point: %w", err)
		}
		points = append(points, p)
	}
	return points, nil
}

// ============================================================
// Journey Stats
// ============================================================

func (d *DB) GetJourneyStats(ctx context.Context, deviceID, period string, limit int) (*pb.JourneyStats, error) {
	// Overall stats
	var stats pb.JourneyStats
	stats.DeviceId = deviceID

	err := d.pool.QueryRow(ctx,
		`SELECT COUNT(*), COALESCE(SUM(total_distance_m), 0),
		        COALESCE(SUM(EXTRACT(EPOCH FROM (COALESCE(ended_at, now()) - started_at)) * 1000), 0)
		 FROM journeys WHERE device_id = $1 AND ended_at IS NOT NULL`, deviceID,
	).Scan(&stats.TotalJourneys, &stats.TotalDistanceM, &stats.TotalDurationMs)
	if err != nil {
		return nil, fmt.Errorf("overall stats: %w", err)
	}

	if stats.TotalJourneys > 0 {
		stats.AvgDistancePerJourney = stats.TotalDistanceM / float64(stats.TotalJourneys)
	}

	// Max speed across all journeys
	_ = d.pool.QueryRow(ctx,
		`SELECT COALESCE(MAX(speed), 0) FROM location_points
		 WHERE device_id = $1`, deviceID,
	).Scan(&stats.MaxSpeed)

	// Daily stats
	var dateTrunc string
	switch period {
	case "week":
		dateTrunc = "week"
	case "month":
		dateTrunc = "month"
	default:
		dateTrunc = "day"
	}

	rows, err := d.pool.Query(ctx,
		fmt.Sprintf(`SELECT DATE_TRUNC('%s', started_at)::date::text,
				        COUNT(*), COALESCE(SUM(total_distance_m), 0),
				        COALESCE(SUM(EXTRACT(EPOCH FROM (COALESCE(ended_at, now()) - started_at)) * 1000), 0)
				 FROM journeys WHERE device_id = $1 AND ended_at IS NOT NULL
				 GROUP BY DATE_TRUNC('%s', started_at)
				 ORDER BY DATE_TRUNC('%s', started_at) DESC LIMIT $2`, dateTrunc, dateTrunc, dateTrunc),
		deviceID, limit,
	)
	if err != nil {
		return nil, fmt.Errorf("daily stats: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var day pb.DayStats
		if err := rows.Scan(&day.Date, &day.JourneyCount, &day.DistanceM, &day.DurationMs); err != nil {
			return nil, fmt.Errorf("scan day stats: %w", err)
		}
		stats.Daily = append(stats.Daily, &day)
	}

	return &stats, nil
}

// ============================================================
// Device IDs (for scheduler)
// ============================================================

func (d *DB) GetAllDeviceIDs(ctx context.Context) ([]string, error) {
	rows, err := d.pool.Query(ctx,
		`SELECT DISTINCT device_id FROM journeys WHERE ended_at IS NOT NULL`,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, nil
}

// ============================================================
// Saved Locations
// ============================================================

func (d *DB) SaveLocation(ctx context.Context, deviceID, name string, lat, lng float64, radiusM float32) (*pb.SavedLocation, error) {
	row := d.pool.QueryRow(ctx,
		`INSERT INTO saved_locations (device_id, name, geog, radius_m)
		 VALUES ($1, $2, ST_SetSRID(ST_MakePoint($3, $4), 4326)::geography, $5)
		 RETURNING id::text, device_id, name, ST_Y(geog::geometry), ST_X(geog::geometry), radius_m, EXTRACT(EPOCH FROM created_at)`,
		deviceID, name, lng, lat, radiusM,
	)
	var loc pb.SavedLocation
	var createdAt float64
	if err := row.Scan(&loc.Id, &loc.DeviceId, &loc.Name, &loc.Latitude, &loc.Longitude, &loc.RadiusM, &createdAt); err != nil {
		return nil, fmt.Errorf("insert saved location: %w", err)
	}
	loc.CreatedAt = int64(createdAt)
	return &loc, nil
}

func (d *DB) GetSavedLocations(ctx context.Context, deviceID string) ([]*pb.SavedLocation, error) {
	rows, err := d.pool.Query(ctx,
		`SELECT id::text, device_id, name, ST_Y(geog::geometry), ST_X(geog::geometry), radius_m, EXTRACT(EPOCH FROM created_at)
		 FROM saved_locations WHERE device_id = $1 ORDER BY created_at DESC`, deviceID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var locs []*pb.SavedLocation
	for rows.Next() {
		var loc pb.SavedLocation
		var createdAt float64
		if err := rows.Scan(&loc.Id, &loc.DeviceId, &loc.Name, &loc.Latitude, &loc.Longitude, &loc.RadiusM, &createdAt); err != nil {
			return nil, err
		}
		loc.CreatedAt = int64(createdAt)
		locs = append(locs, &loc)
	}
	return locs, nil
}

func (d *DB) DeleteSavedLocation(ctx context.Context, locationID string) error {
	_, err := d.pool.Exec(ctx, `DELETE FROM saved_locations WHERE id = $1`, locationID)
	return err
}

// ============================================================
// Share Links
// ============================================================

func (d *DB) CreateShareLink(ctx context.Context, journeyID, deviceID string, durationHours int64) (*pb.ShareLink, error) {
	var row pgx.Row
	if durationHours > 0 {
		row = d.pool.QueryRow(ctx,
			`INSERT INTO share_links (journey_id, device_id, expires_at)
			 VALUES ($1, $2, now() || $3::text || ' hours')
			 RETURNING id::text, journey_id::text, EXTRACT(EPOCH FROM expires_at)`,
			journeyID, deviceID, fmt.Sprintf("%d", durationHours),
		)
	} else {
		row = d.pool.QueryRow(ctx,
			`INSERT INTO share_links (journey_id, device_id)
			 VALUES ($1, $2)
			 RETURNING id::text, journey_id::text, 0::float`,
			journeyID, deviceID,
		)
	}

	var link pb.ShareLink
	var expiresAt float64
	if err := row.Scan(&link.Id, &link.JourneyId, &expiresAt); err != nil {
		return nil, fmt.Errorf("create share link: %w", err)
	}
	link.ExpiresAt = int64(expiresAt)
	link.Url = fmt.Sprintf("/share/%s", link.Id)
	return &link, nil
}

func (d *DB) GetShareLink(ctx context.Context, shareID string) (*pb.ShareLink, error) {
	row := d.pool.QueryRow(ctx,
		`SELECT id::text, journey_id::text, EXTRACT(EPOCH FROM expires_at), (expires_at IS NOT NULL AND expires_at < now())
		 FROM share_links WHERE id = $1`, shareID,
	)
	var link pb.ShareLink
	var expiresAt float64
	if err := row.Scan(&link.Id, &link.JourneyId, &expiresAt, &link.Expired); err != nil {
		return nil, fmt.Errorf("share link not found")
	}
	link.ExpiresAt = int64(expiresAt)
	link.Url = fmt.Sprintf("/share/%s", link.Id)
	return &link, nil
}

// ============================================================
// Export
// ============================================================

func (d *DB) ExportJourney(ctx context.Context, journeyID, format string) ([]byte, string, error) {
	points, err := d.GetJourneyPoints(ctx, journeyID)
	if err != nil {
		return nil, "", err
	}

	switch format {
	case "gpx":
		return exportGPX(journeyID, points)
	case "geojson":
		return exportGeoJSON(journeyID, points)
	case "csv":
		return exportCSV(points)
	default:
		return exportGPX(journeyID, points)
	}
}

func exportGPX(journeyID string, points []LocationPoint) ([]byte, string, error) {
	gpx := `<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="bwhere">
  <trk><name>` + journeyID + `</name><trkseg>`
	for _, p := range points {
		gpx += fmt.Sprintf("\n    <trkpt lat=\"%f\" lon=\"%f\"><ele>%f</ele><time>%s</time></trkpt>",
			p.Latitude, p.Longitude, p.Altitude, p.RecordedAt.Format(time.RFC3339))
	}
	gpx += "\n  </trkseg></trk>\n</gpx>"
	return []byte(gpx), journeyID + ".gpx", nil
}

func exportGeoJSON(journeyID string, points []LocationPoint) ([]byte, string, error) {
	coords := "["
	for i, p := range points {
		if i > 0 {
			coords += ","
		}
		coords += fmt.Sprintf("[%f,%f]", p.Longitude, p.Latitude)
	}
	coords += "]"
	geojson := fmt.Sprintf(`{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"journey_id":"%s"},"geometry":{"type":"LineString","coordinates":%s}}]}`,
		journeyID, coords)
	return []byte(geojson), journeyID + ".geojson", nil
}

func exportCSV(points []LocationPoint) ([]byte, string, error) {
	csv := "latitude,longitude,accuracy,speed,altitude,heading,recorded_at\n"
	for _, p := range points {
		csv += fmt.Sprintf("%f,%f,%f,%f,%f,%f,%s\n",
			p.Latitude, p.Longitude, p.Accuracy, p.Speed, p.Altitude, p.Heading, p.RecordedAt.Format(time.RFC3339))
	}
	return []byte(csv), "journey.csv", nil
}
