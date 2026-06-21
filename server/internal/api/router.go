package api

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"

	"bwhere/internal/auth"
	"bwhere/internal/db"
	"bwhere/internal/notifications"
)

type Router struct {
	db      *db.DB
	authMgr *auth.DeviceCodeManager
	notif   *notifications.OneSignalClient
	engine  *gin.Engine
}

func NewRouter(database *db.DB, authMgr *auth.DeviceCodeManager) *Router {
	gin.SetMode(gin.ReleaseMode)
	engine := gin.New()
	engine.Use(gin.Logger(), gin.Recovery(), corsMiddleware())

	r := &Router{
		db:      database,
		authMgr: authMgr,
		notif:   notifications.NewOneSignalClient(),
		engine:  engine,
	}
	r.registerRoutes()
	return r
}

func (r *Router) Engine() *gin.Engine {
	return r.engine
}

func (r *Router) registerRoutes() {
	r.engine.GET("/health", r.health)

	auth := r.engine.Group("/auth")
	{
		auth.POST("/activate", r.activateDevice)
	}

	api := r.engine.Group("/api")
	{
		api.GET("/export", r.exportJourney)
		api.POST("/share", r.createShareLink)
		api.GET("/share/:id", r.getShareLink)
		api.POST("/notifications/test", r.sendTestNotification)
		api.POST("/webhooks/hasura", r.handleHasuraWebhook)
	}
}

func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.Request.Header.Get("Origin")
		if origin == "" {
			origin = "*"
		}
		c.Header("Access-Control-Allow-Origin", origin)
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization, x-api-key")
		c.Header("Access-Control-Allow-Credentials", "true")
		c.Header("Access-Control-Max-Age", "86400")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

func (r *Router) health(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func (r *Router) activateDevice(c *gin.Context) {
	var req struct {
		DeviceCode string `json:"device_code" binding:"required"`
		UserID     string `json:"user_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	result, err := r.authMgr.Activate(c.Request.Context(), req.DeviceCode, req.UserID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (r *Router) exportJourney(c *gin.Context) {
	journeyID := c.Query("journey_id")
	format := c.Query("format")
	if journeyID == "" || format == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "journey_id and format required"})
		return
	}

	data, filename, err := r.db.ExportJourney(c.Request.Context(), journeyID, format)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	var contentType string
	switch format {
	case "gpx":
		contentType = "application/gpx+xml"
	case "geojson":
		contentType = "application/geo+json"
	case "csv":
		contentType = "text/csv"
	default:
		contentType = "application/octet-stream"
	}

	c.Header("Content-Type", contentType)
	c.Header("Content-Disposition", "attachment; filename="+filename)
	c.Data(http.StatusOK, contentType, data)
}

func (r *Router) createShareLink(c *gin.Context) {
	var req struct {
		JourneyID     string `json:"journey_id" binding:"required"`
		DurationHours int64  `json:"duration_hours"`
		DeviceID      string `json:"device_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	link, err := r.db.CreateShareLink(c.Request.Context(), req.JourneyID, req.DeviceID, req.DurationHours)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, link)
}

func (r *Router) getShareLink(c *gin.Context) {
	shareID := c.Param("id")
	if shareID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "id required"})
		return
	}

	link, err := r.db.GetShareLink(c.Request.Context(), shareID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}

	c.JSON(http.StatusOK, link)
}

// ============================================================
// OneSignal Notifications
// ============================================================

func (r *Router) sendTestNotification(c *gin.Context) {
	result, err := r.notif.SendToAll(c.Request.Context(),
		"BWhere Test",
		"This is a test notification from Bro Where Are You.",
		map[string]string{"type": "test"},
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"id": result.ID, "recipients": result.Recipients})
}

// ============================================================
// Hasura Event Trigger Webhook
// ============================================================

type HasuraEvent struct {
	Event struct {
		Op   string         `json:"op"`
		Data map[string]any `json:"data"`
	} `json:"event"`
	Table struct {
		Schema string `json:"schema"`
		Name   string `json:"name"`
	} `json:"table"`
}

func (r *Router) handleHasuraWebhook(c *gin.Context) {
	// Verify webhook secret
	secret := c.GetHeader("x-hasura-webhook-secret")
	expected := os.Getenv("HASURA_WEBHOOK_SECRET")
	if expected != "" && secret != expected {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid secret"})
		return
	}

	var event HasuraEvent
	if err := c.ShouldBindJSON(&event); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	switch event.Table.Name {
	case "journeys":
		r.handleJourneyEvent(c, event)
	default:
		c.JSON(http.StatusOK, gin.H{"message": "ignored"})
	}
}

func (r *Router) handleJourneyEvent(c *gin.Context, event HasuraEvent) {
	data := event.Event.Data

	// Hasura nests row data under "new" and "old"
	newData, _ := data["new"].(map[string]any)
	oldData, _ := data["old"].(map[string]any)
	if newData == nil {
		c.JSON(http.StatusOK, gin.H{"message": "no data"})
		return
	}

	// Handle journey completion (UPDATE with ended_at set)
	if event.Event.Op == "UPDATE" {
		endedAt, hasEnded := newData["ended_at"]
		var oldEnded any
		if oldData != nil {
			oldEnded = oldData["ended_at"]
		}

		if hasEnded && endedAt != nil && oldEnded == nil {
			label, _ := newData["label"].(string)
			deviceID, _ := newData["device_id"].(string)
			journeyID, _ := newData["id"].(string)
			distance, _ := newData["total_distance_m"].(float64)

			heading := "Journey Complete"
			body := fmt.Sprintf("Your %q journey ended. %.0fm recorded.", label, distance)

		go func() {
			result, err := r.notif.SendToAll(context.Background(), heading, body, map[string]string{
				"type":       "journey_completed",
				"journey_id": journeyID,
				"device_id":  deviceID,
			})
				if err != nil {
					slog.Error("notification failed", "err", err)
				} else {
					slog.Info("notification sent", "id", result.ID, "recipients", result.Recipients)
				}
			}()
		}
	}

	// Handle new journey (INSERT)
	if event.Event.Op == "INSERT" {
		label, _ := newData["label"].(string)
		deviceID, _ := newData["device_id"].(string)
		journeyID, _ := newData["id"].(string)

		go func() {
			result, err := r.notif.SendToAll(context.Background(),
				"Journey Started",
				fmt.Sprintf("Tracking started: %q", label),
				map[string]string{
					"type":       "journey_started",
					"journey_id": journeyID,
					"device_id":  deviceID,
				},
			)
			if err != nil {
				slog.Error("notification failed", "err", err)
			} else {
				slog.Info("notification sent", "id", result.ID, "recipients", result.Recipients)
			}
		}()
	}

	c.JSON(http.StatusOK, gin.H{"message": "processed"})
}

// sendDailySummary sends a daily summary notification.
func (r *Router) SendDailySummary(ctx context.Context, deviceID string) {
	journeys, _, err := r.db.GetJourneys(ctx, deviceID, 100, 0)
	if err != nil {
		slog.Error("daily summary: get journeys failed", "err", err)
		return
	}

	today := time.Now().UTC().Truncate(24 * time.Hour)
	count := 0
	var totalDist float64
	for _, j := range journeys {
		if j.StartedAt.After(today) && j.EndedAt != nil {
			count++
			totalDist += j.TotalDistanceM
		}
	}

	if count == 0 {
		return
	}

	distStr := fmt.Sprintf("%.0fm", totalDist)
	if totalDist >= 1000 {
		distStr = fmt.Sprintf("%.1fkm", totalDist/1000)
	}

	_, err = r.notif.SendToUser(ctx, deviceID,
		"Daily Summary",
		fmt.Sprintf("Today: %d journeys, %s total.", count, distStr),
		map[string]string{"type": "daily_summary"},
	)
	if err != nil {
		slog.Error("daily summary notification failed", "err", err)
	}
}
