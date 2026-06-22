package hasura

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type MetadataApplier struct {
	endpoint    string
	adminSecret string
	client      *http.Client
}

func NewMetadataApplier(endpoint, adminSecret string) *MetadataApplier {
	return &MetadataApplier{
		endpoint:    endpoint,
		adminSecret: adminSecret,
		client:      &http.Client{Timeout: 30 * time.Second},
	}
}

type permEntry struct {
	table   string
	columns []string
}

// ApplyPermissions sets select_permissions for the user role on required tables.
func (m *MetadataApplier) ApplyPermissions() error {
	entries := []permEntry{
		{"devices", []string{"id", "name", "platform", "last_seen", "active"}},
		{"journeys", []string{"id", "device_id", "label", "started_at", "ended_at", "total_distance_m", "source", "transport_mode", "start_place", "end_place"}},
		{"location_points", []string{"journey_id", "device_id", "geog", "accuracy", "speed", "altitude", "heading", "source", "recorded_at"}},
		{"saved_locations_view", []string{"id", "device_id", "name", "latitude", "longitude", "radius_m", "created_at"}},
		{"saved_locations", []string{"id", "device_id", "name", "radius_m", "created_at"}},
		{"share_links", []string{"id", "journey_id", "device_id", "expires_at", "created_at"}},
	}

	for _, e := range entries {
		if err := m.createSelectPermission(e.table, e.columns); err != nil {
			fmt.Printf("[hasura] permission %s: %v\n", e.table, err)
		}
	}
	return nil
}

// ApplyEventTriggers creates event triggers for journey changes.
func (m *MetadataApplier) ApplyEventTriggers() error {
	return m.createEventTrigger("on_journey_changed", "journeys",
		"http://go-server:8088/api/webhooks/hasura",
		[]string{"ended_at"})
}

// TrackView ensures saved_locations_view is tracked.
func (m *MetadataApplier) TrackView() error {
	payload := map[string]any{
		"type": "pg_track_table",
		"args": map[string]any{
			"source": "default",
			"table":  map[string]string{"name": "saved_locations_view", "schema": "public"},
		},
	}
	return m.post(payload)
}

func (m *MetadataApplier) createSelectPermission(table string, columns []string) error {
	payload := map[string]any{
		"type": "pg_create_select_permission",
		"args": map[string]any{
			"source": "default",
			"table":  map[string]string{"name": table, "schema": "public"},
			"role":   "user",
			"permission": map[string]any{
				"columns": columns,
				"filter":  map[string]any{},
			},
		},
	}
	return m.post(payload)
}

func (m *MetadataApplier) createEventTrigger(name, table, webhook string, updateColumns []string) error {
	payload := map[string]any{
		"type": "pg_create_event_trigger",
		"args": map[string]any{
			"name":    name,
			"source":  "default",
			"table":   map[string]string{"name": table, "schema": "public"},
			"webhook": webhook,
			"headers": []map[string]string{
				{"name": "x-hasura-webhook-secret", "value_from_env": "HASURA_WEBHOOK_SECRET"},
			},
			"insert": map[string]string{"columns": "*"},
			"update": map[string]any{"columns": updateColumns},
			"retry_conf": map[string]any{
				"num_retries": 3, "interval_sec": 10, "timeout_sec": 60,
			},
		},
	}
	return m.post(payload)
}

func (m *MetadataApplier) post(payload any) error {
	body, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", m.endpoint+"/v1/metadata", bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("x-hasura-admin-secret", m.adminSecret)

	resp, err := m.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusOK {
		return nil
	}

	// Read response to check for "already-exists" (not a real error)
	var result struct {
		Error string `json:"error"`
		Code  string `json:"code"`
	}
	json.NewDecoder(resp.Body).Decode(&result)

	if result.Code == "already-exists" || result.Code == "already-tracked" {
		return nil // idempotent — already applied
	}

	return fmt.Errorf("status %d: %s", resp.StatusCode, result.Error)
}
