package scheduler

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"bwhere/internal/db"
	"bwhere/internal/notifications"
)

type Scheduler struct {
	db         *db.DB
	notif      *notifications.OneSignalClient
	summHour   int
	summMinute int
}

func New(database *db.DB, notif *notifications.OneSignalClient, hour, minute int) *Scheduler {
	return &Scheduler{
		db:         database,
		notif:      notif,
		summHour:   hour,
		summMinute: minute,
	}
}

// Start runs the scheduler in a background goroutine.
func (s *Scheduler) Start(ctx context.Context) {
	go s.run(ctx)
	slog.Info("scheduler started", "summary_hour", s.summHour, "summary_minute", s.summMinute)
}

func (s *Scheduler) run(ctx context.Context) {
	for {
		now := time.Now()
		next := time.Date(now.Year(), now.Month(), now.Day(), s.summHour, s.summMinute, 0, 0, now.Location())
		if now.After(next) {
			next = next.Add(24 * time.Hour)
		}
		delay := next.Sub(now)
		slog.Info("next daily summary", "at", next.Format(time.RFC3339), "in", delay)

		select {
		case <-ctx.Done():
			return
		case <-time.After(delay):
			s.sendDailySummary(ctx)
		}
	}
}

func (s *Scheduler) sendDailySummary(ctx context.Context) {
	slog.Info("running daily summary")

	// Get all devices
	devices, err := s.db.GetAllDeviceIDs(ctx)
	if err != nil {
		slog.Error("daily summary: get devices failed", "err", err)
		return
	}

	today := time.Now().UTC().Truncate(24 * time.Hour)

	for _, deviceID := range devices {
		journeys, _, err := s.db.GetJourneys(ctx, deviceID, 200, 0)
		if err != nil {
			slog.Error("daily summary: get journeys failed", "device", deviceID, "err", err)
			continue
		}

		count := 0
		var totalDist float64
		var totalDuration time.Duration
		for _, j := range journeys {
			if j.StartedAt.After(today) && j.EndedAt != nil {
				count++
				totalDist += j.TotalDistanceM
				totalDuration += j.EndedAt.Sub(j.StartedAt)
			}
		}

		if count == 0 {
			continue
		}

		distStr := fmt.Sprintf("%.0fm", totalDist)
		if totalDist >= 1000 {
			distStr = fmt.Sprintf("%.1fkm", totalDist/1000)
		}

		durStr := fmt.Sprintf("%dm", int(totalDuration.Minutes()))
		if totalDuration.Hours() >= 1 {
			durStr = fmt.Sprintf("%.1fh", totalDuration.Hours())
		}

		heading := "Daily Summary"
		body := fmt.Sprintf("Today: %d journeys, %s in %s.", count, distStr, durStr)

		result, err := s.notif.SendToAll(ctx, heading, body, map[string]string{
			"type": "daily_summary",
		})
		if err != nil {
			slog.Error("daily summary: send failed", "err", err)
		} else {
			slog.Info("daily summary sent", "recipients", result.Recipients, "journeys", count)
		}
	}
}
