package routing

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"
)

type Point struct {
	Lat float64
	Lng float64
}

type MatchResult struct {
	MatchedPoints []Point
	Shape         string // encoded polyline
	Confidence    float64
}

type ValhallaClient struct {
	baseURL string
	client  *http.Client
}

func NewValhallaClient() *ValhallaClient {
	url := os.Getenv("VALHALLA_URL")
	if url == "" {
		url = "http://localhost:8002"
	}
	return &ValhallaClient{
		baseURL: url,
		client:  &http.Client{Timeout: 30 * time.Second},
	}
}

// TraceRoute sends a sequence of GPS points to Valhalla and returns the snapped route.
func (c *ValhallaClient) TraceRoute(ctx context.Context, points []Point, costing string) (*MatchResult, error) {
	if len(points) < 2 {
		return nil, fmt.Errorf("need at least 2 points")
	}

	// Build request body
	shape := make([]map[string]float64, len(points))
	for i, p := range points {
		shape[i] = map[string]float64{"lat": p.Lat, "lon": p.Lng}
	}

	body := map[string]any{
		"shape":       shape,
		"costing":     costing,
		"shape_match": "map_snap",
		"filters": map[string]any{
			"attributes": []string{"matched_points", "shape"},
			"action":     "include",
		},
	}

	jsonBody, err := json.Marshal(body)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	url := fmt.Sprintf("%s/trace_route", c.baseURL)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("valhalla request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("valhalla returned %d", resp.StatusCode)
	}

	var result struct {
		Trip struct {
			Legs []struct {
				Shape       string `json:"shape"`
				Maneuvers   []struct {
					BeginShapeIndex int `json:"begin_shape_index"`
					EndShapeIndex   int `json:"end_shape_index"`
				} `json:"maneuvers"`
			} `json:"legs"`
			Summary struct {
				Length   float64 `json:"length"`
				Time     float64 `json:"time"`
			} `json:"summary"`
		} `json:"trip"`
		MatchedPoints []struct {
			Lat        float64 `json:"lat"`
			Lon        float64 `json:"lon"`
			MatchType  string  `json:"match_type"`
			Confidence float64 `json:"confidence"`
		} `json:"matched_points"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decode response: %w", err)
	}

	// Extract matched points
	matched := make([]Point, len(result.MatchedPoints))
	var totalConfidence float64
	for i, mp := range result.MatchedPoints {
		matched[i] = Point{Lat: mp.Lat, Lng: mp.Lon}
		totalConfidence += mp.Confidence
	}

	avgConfidence := 0.0
	if len(result.MatchedPoints) > 0 {
		avgConfidence = totalConfidence / float64(len(result.MatchedPoints))
	}

	routeShape := ""
	if len(result.Trip.Legs) > 0 {
		routeShape = result.Trip.Legs[0].Shape
	}

	return &MatchResult{
		MatchedPoints: matched,
		Shape:         routeShape,
		Confidence:    avgConfidence,
	}, nil
}

// IsAvailable checks if Valhalla is reachable.
func (c *ValhallaClient) IsAvailable(ctx context.Context) bool {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.baseURL+"/status", nil)
	if err != nil {
		return false
	}
	resp, err := c.client.Do(req)
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	return resp.StatusCode == http.StatusOK
}
