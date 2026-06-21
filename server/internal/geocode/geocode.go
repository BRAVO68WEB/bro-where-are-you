package geocode

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type Result struct {
	DisplayName string
	Lat         float64
	Lon         float64
}

// ReverseGeocode calls Nominatim to get a place name for lat/lng.
func ReverseGeocode(lat, lng float64) (string, error) {
	u := fmt.Sprintf("https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=%f&lon=%f&zoom=18&addressdetails=1", lat, lng)

	client := &http.Client{Timeout: 5 * time.Second}
	req, err := http.NewRequest("GET", u, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("User-Agent", "bwhere-app/1.0")

	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != 200 {
		return "", fmt.Errorf("nominatim returned %d", resp.StatusCode)
	}

	var result struct {
		DisplayName string `json:"display_name"`
		Address     struct {
			Road          string `json:"road"`
			Suburb        string `json:"suburb"`
			City          string `json:"city"`
			Town          string `json:"town"`
			Village       string `json:"village"`
			State         string `json:"state"`
			Country       string `json:"country"`
			Neighbourhood string `json:"neighbourhood"`
		} `json:"address"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}

	// Build a short readable name
	name := shortName(result.Address)
	if name == "" {
		name = result.DisplayName
		if len(name) > 50 {
			name = name[:50] + "..."
		}
	}
	return name, nil
}

func shortName(addr struct {
	Road          string `json:"road"`
	Suburb        string `json:"suburb"`
	City          string `json:"city"`
	Town          string `json:"town"`
	Village       string `json:"village"`
	State         string `json:"state"`
	Country       string `json:"country"`
	Neighbourhood string `json:"neighbourhood"`
}) string {
	// Priority: neighbourhood/road + city
	area := addr.Neighbourhood
	if area == "" {
		area = addr.Suburb
	}
	if area == "" {
		area = addr.Road
	}
	city := addr.City
	if city == "" {
		city = addr.Town
	}
	if city == "" {
		city = addr.Village
	}

	if area != "" && city != "" {
		return area + ", " + city
	}
	if city != "" {
		return city
	}
	if area != "" {
		return area
	}
	return ""
}

// ClassifyTransportMode determines transport mode from average speed.
func ClassifyTransportMode(avgSpeedMps float64) string {
	avgKmh := avgSpeedMps * 3.6
	switch {
	case avgKmh < 2:
		return "walking"
	case avgKmh < 15:
		return "cycling"
	case avgKmh < 60:
		return "driving"
	default:
		return "highway"
	}
}

// GeocodeURL builds a Nominatim URL (for logging/debug).
func GeocodeURL(lat, lng float64) string {
	return fmt.Sprintf("https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=%f&lon=%f&zoom=18", lat, lng)
}
