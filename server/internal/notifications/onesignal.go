package notifications

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"time"
)

const oneSignalAPIURL = "https://api.onesignal.com/notifications"

type OneSignalClient struct {
	apiKey string
	appID  string
	client *http.Client
}

func NewOneSignalClient() *OneSignalClient {
	return &OneSignalClient{
		apiKey: os.Getenv("ONESIGNAL_API_KEY"),
		appID:  os.Getenv("ONESIGNAL_APP_ID"),
		client: &http.Client{Timeout: 10 * time.Second},
	}
}

type NotificationRequest struct {
	AppID            string            `json:"app_id"`
	TargetChannel    string            `json:"target_channel,omitempty"`
	Headings         map[string]string `json:"headings,omitempty"`
	Contents         map[string]string `json:"contents"`
	IncludedSegments []string          `json:"included_segments,omitempty"`
	IncludeAliases   *AliasTarget      `json:"include_aliases,omitempty"`
	IncludePlayerIDs []string          `json:"include_player_ids,omitempty"`
	Filters          []Filter          `json:"filters,omitempty"`
	URL              string            `json:"url,omitempty"`
	Data             map[string]string `json:"data,omitempty"`
	Priority         int               `json:"priority,omitempty"`
}

type AliasTarget struct {
	ExternalID []string `json:"external_id"`
}

type Filter struct {
	Field    string `json:"field"`
	Key      string `json:"key,omitempty"`
	Relation string `json:"relation"`
	Value    string `json:"value,omitempty"`
}

type NotificationResponse struct {
	ID         string `json:"id"`
	Recipients int    `json:"recipients"`
	Errors     any    `json:"errors,omitempty"`
}

func (c *OneSignalClient) SendToAll(ctx context.Context, heading, body string, data map[string]string) (*NotificationResponse, error) {
	// Fetch player IDs from v1 API (segment-based delivery is unreliable with v2 keys)
	playerIDs, err := c.fetchPlayerIDs(ctx)
	if err != nil {
		slog.Error("fetch players failed, falling back to segment", "err", err)
		// Fallback to segment
		return c.send(ctx, NotificationRequest{
			AppID:            c.appID,
			TargetChannel:    "push",
			Headings:         map[string]string{"en": heading},
			Contents:         map[string]string{"en": body},
			IncludedSegments: []string{"All"},
			Data:             data,
			Priority:         10,
		})
	}
	if len(playerIDs) == 0 {
		return &NotificationResponse{Recipients: 0}, nil
	}

	req := NotificationRequest{
		AppID:            c.appID,
		Headings:         map[string]string{"en": heading},
		Contents:         map[string]string{"en": body},
		IncludePlayerIDs: playerIDs,
		Data:             data,
		Priority:         10,
	}
	return c.send(ctx, req)
}

func (c *OneSignalClient) fetchPlayerIDs(ctx context.Context) ([]string, error) {
	url := fmt.Sprintf("https://onesignal.com/api/v1/players?app_id=%s&limit=300", c.appID)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	httpReq.Header.Set("Authorization", "Key "+c.apiKey)

	resp, err := c.client.Do(httpReq)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("players API returned %d", resp.StatusCode)
	}

	var result struct {
		TotalCount int `json:"total_count"`
		Players    []struct {
			ID string `json:"id"`
		} `json:"players"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	slog.Info("fetched players", "total", result.TotalCount, "count", len(result.Players))

	ids := make([]string, len(result.Players))
	for i, p := range result.Players {
		ids[i] = p.ID
	}
	return ids, nil
}

func (c *OneSignalClient) SendToUser(ctx context.Context, externalID, heading, body string, data map[string]string) (*NotificationResponse, error) {
	req := NotificationRequest{
		AppID:         c.appID,
		TargetChannel: "push",
		Headings:      map[string]string{"en": heading},
		Contents:      map[string]string{"en": body},
		IncludeAliases: &AliasTarget{
			ExternalID: []string{externalID},
		},
		Data:     data,
		Priority: 10,
	}
	return c.send(ctx, req)
}

func (c *OneSignalClient) send(ctx context.Context, req NotificationRequest) (*NotificationResponse, error) {
	if c.apiKey == "" || c.appID == "" {
		return nil, fmt.Errorf("onesignal not configured (missing API_KEY or APP_ID)")
	}

	body, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("marshal: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, oneSignalAPIURL, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json; charset=utf-8")
	httpReq.Header.Set("Authorization", "Key "+c.apiKey)

	resp, err := c.client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("send: %w", err)
	}
	defer func() { _ = resp.Body.Close() }()

	var result NotificationResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decode: %w", err)
	}

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return &result, fmt.Errorf("onesignal error (status %d): %+v", resp.StatusCode, result.Errors)
	}

	return &result, nil
}
