package geofence

import (
	"context"
	"log/slog"
	"math"
	"sync"

	"bwhere/internal/db"
	"bwhere/internal/notifications"
)

type Place struct {
	Name    string
	Lat     float64
	Lng     float64
	RadiusM float32
}

type Checker struct {
	db    *db.DB
	notif *notifications.OneSignalClient

	mu    sync.RWMutex
	state map[string]map[string]bool // deviceID -> set of place names
}

func NewChecker(database *db.DB, notif *notifications.OneSignalClient) *Checker {
	return &Checker{
		db:    database,
		notif: notif,
		state: make(map[string]map[string]bool),
	}
}

// Check evaluates a location point against all saved locations for the device.
func (c *Checker) Check(ctx context.Context, deviceID string, lat, lng float64) {
	places, err := c.getPlaces(ctx, deviceID)
	if err != nil || len(places) == 0 {
		return
	}

	inside := make(map[string]bool)
	for _, p := range places {
		dist := haversineM(lat, lng, p.Lat, p.Lng)
		if dist <= float64(p.RadiusM) {
			inside[p.Name] = true
		}
	}

	c.mu.Lock()
	prev := c.state[deviceID]
	if prev == nil {
		prev = make(map[string]bool)
	}

	for name := range prev {
		if !inside[name] {
			slog.Info("geofence exit", "device", deviceID, "place", name)
			go c.sendNotification(ctx, "Left "+name, "You've left "+name+".", "geofence_exit")
		}
	}
	for name := range inside {
		if !prev[name] {
			slog.Info("geofence enter", "device", deviceID, "place", name)
			go c.sendNotification(ctx, "Arrived at "+name, "You've arrived at "+name+".", "geofence_enter")
		}
	}

	c.state[deviceID] = inside
	c.mu.Unlock()
}

func (c *Checker) sendNotification(ctx context.Context, heading, body, eventType string) {
	result, err := c.notif.SendToAll(ctx, heading, body, map[string]string{"type": eventType})
	if err != nil {
		slog.Error("geofence notification failed", "err", err)
	} else if result != nil {
		slog.Info("geofence notification sent", "id", result.ID)
	}
}

func (c *Checker) getPlaces(ctx context.Context, deviceID string) ([]Place, error) {
	rows, err := c.db.Pool().Query(ctx,
		`SELECT name, ST_Y(geog::geometry), ST_X(geog::geometry), radius_m
		 FROM saved_locations WHERE device_id = $1`, deviceID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var places []Place
	for rows.Next() {
		var p Place
		if err := rows.Scan(&p.Name, &p.Lat, &p.Lng, &p.RadiusM); err != nil {
			return nil, err
		}
		places = append(places, p)
	}
	return places, nil
}

func haversineM(lat1, lng1, lat2, lng2 float64) float64 {
	const R = 6371000.0
	toRad := math.Pi / 180
	dLat := (lat2 - lat1) * toRad
	dLng := (lng2 - lng1) * toRad
	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(lat1*toRad)*math.Cos(lat2*toRad)*
			math.Sin(dLng/2)*math.Sin(dLng/2)
	return R * 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
}
