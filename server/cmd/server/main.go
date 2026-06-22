package main

import (
	"context"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c" //nolint:staticcheck // no h2c replacement yet
	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/reflection"

	"bwhere/internal/api"
	"bwhere/internal/auth"
	"bwhere/internal/batch"
	"bwhere/internal/db"
	"bwhere/internal/geofence"
	grpcHandler "bwhere/internal/grpc"
	hasuraPkg "bwhere/internal/hasura"
	"bwhere/internal/notifications"
	"bwhere/internal/scheduler"
	pb "bwhere/pb/location/v1"
)

func main() {
	if err := run(); err != nil {
		slog.Error("startup failed", "err", err)
		os.Exit(1)
	}
}

func run() error {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Database
	dbURL := envOr("DB_URL", "postgres://bwhere:bwhere@localhost:5432/bwhere")
	database, err := db.New(ctx, dbURL)
	if err != nil {
		return fmt.Errorf("db init: %w", err)
	}
	defer database.Close()

	// Run migrations
	if err := db.RunMigrations(ctx, database.Pool()); err != nil {
		return fmt.Errorf("migrations: %w", err)
	}

	// Apply Hasura metadata (permissions + event triggers)
	hasuraURL := envOr("HASURA_URL", "http://hasura:8080")
	hasuraSecret := envOr("HASURA_ADMIN_SECRET", "")
	if hasuraSecret != "" {
		go func() {
			// Retry loop — Hasura may not be ready immediately
			for i := 0; i < 10; i++ {
				time.Sleep(3 * time.Second)
				applier := hasuraPkg.NewMetadataApplier(hasuraURL, hasuraSecret)
				if err := applier.TrackView(); err == nil {
					if err := applier.ApplyPermissions(); err != nil {
						slog.Warn("hasura permissions apply failed", "err", err)
					}
					if err := applier.ApplyEventTriggers(); err != nil {
						slog.Warn("hasura event triggers apply failed", "err", err)
					}
					slog.Info("hasura metadata applied")
					return
				}
			}
			slog.Warn("hasura metadata apply skipped — hasura not reachable")
		}()
	}

	// OneSignal notifications client
	notifClient := notifications.NewOneSignalClient()

	// Geofence checker
	geoChecker := geofence.NewChecker(database, notifClient)

	// Batch inserter with geofence callback
	inserter := batch.New(database,
		batch.WithPointCallback(func(ctx context.Context, p db.LocationPoint) {
			geoChecker.Check(ctx, p.DeviceID, p.Latitude, p.Longitude)
		}),
	)
	inserter.Start(ctx)
	defer inserter.Stop()

	// Auth — Device Code Manager + JWT
	jwtSecret := envOr("JWT_SECRET", "change-me-in-production")
	authMgr := auth.NewDeviceCodeManager(database.Pool(), jwtSecret)

	// Daily summary scheduler (default 8 PM)
	sched := scheduler.New(database, notifClient, 20, 0)
	sched.Start(ctx)

	// gRPC server
	unaryAuth, streamAuth := auth.Interceptor(authMgr)
	grpcServer := grpc.NewServer(
		grpc.UnaryInterceptor(unaryAuth),
		grpc.ChainStreamInterceptor(streamAuth),
		grpc.KeepaliveEnforcementPolicy(keepalive.EnforcementPolicy{
			MinTime:             10 * time.Second,
			PermitWithoutStream: true,
		}),
		grpc.KeepaliveParams(keepalive.ServerParameters{
			MaxConnectionIdle:     5 * time.Minute,
			MaxConnectionAge:      10 * time.Minute,
			MaxConnectionAgeGrace: 30 * time.Second,
			Time:                  30 * time.Second,
			Timeout:               10 * time.Second,
		}),
	)

	svc := grpcHandler.New(database, inserter, authMgr)
	pb.RegisterLocationServiceServer(grpcServer, svc)
	reflection.Register(grpcServer)

	// Gin HTTP router
	router := api.NewRouter(database, authMgr)

	// gRPC listener
	grpcPort := envOr("GRPC_PORT", "50051")
	grpcLis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		return fmt.Errorf("grpc listen: %w", err)
	}

	// HTTP listener
	httpPort := envOr("HTTP_PORT", "8088")

	// h2c handler for gRPC
	h2s := &http2.Server{}
	h2cHandler := h2c.NewHandler(grpcServer, h2s) //nolint:staticcheck // no replacement for gRPC h2c yet

	slog.Info("gRPC server starting", "port", grpcPort)
	slog.Info("HTTP server starting", "port", httpPort)
	slog.Info("geofence checker active")
	slog.Info("daily summary scheduler active", "hour", 20, "minute", 0)

	// Graceful shutdown
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		slog.Info("shutting down")
		grpcServer.GracefulStop()
		cancel()
	}()

	// Start gRPC server
	go func() {
		if err := http.Serve(grpcLis, h2cHandler); err != nil {
			slog.Error("grpc serve failed", "err", err)
		}
	}()

	// Start HTTP server (Gin)
	if err := router.Engine().Run(":" + httpPort); err != nil {
		return fmt.Errorf("http serve: %w", err)
	}
	return nil
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
