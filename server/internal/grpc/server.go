package grpc

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"time"

	"bwhere/internal/auth"
	"bwhere/internal/batch"
	"bwhere/internal/db"
	pb "bwhere/pb/location/v1"
)

type Server struct {
	pb.UnimplementedLocationServiceServer
	db      *db.DB
	inserter *batch.Inserter
	auth    *auth.DeviceCodeManager
}

func New(database *db.DB, inserter *batch.Inserter, authMgr *auth.DeviceCodeManager) *Server {
	return &Server{
		db:       database,
		inserter: inserter,
		auth:     authMgr,
	}
}

// ============================================================
// Auth RPCs
// ============================================================

func (s *Server) RequestDeviceCode(ctx context.Context, req *pb.DeviceCodeRequest) (*pb.DeviceCodeResponse, error) {
	code, err := s.auth.GenerateCode(ctx, req.DeviceName, req.Platform)
	if err != nil {
		slog.Error("request device code failed", "err", err)
		return nil, err
	}
	slog.Info("device code generated", "code", code.DeviceCode, "device", req.DeviceName)
	return &pb.DeviceCodeResponse{
		DeviceCode: code.DeviceCode,
		ExpiresAt:  code.ExpiresAt.UnixMilli(),
		Interval:   5,
	}, nil
}

func (s *Server) PollDeviceActivation(ctx context.Context, req *pb.PollActivationRequest) (*pb.DeviceActivationResponse, error) {
	result, err := s.auth.Poll(ctx, req.DeviceCode)
	if err != nil {
		return &pb.DeviceActivationResponse{Activated: false}, nil
	}
	return &pb.DeviceActivationResponse{
		Activated:   result.Activated,
		DeviceToken: result.DeviceToken,
		DeviceId:    result.DeviceID,
		DeviceName:  result.DeviceName,
	}, nil
}

// ============================================================
// Journey RPCs
// ============================================================

func (s *Server) StartJourney(ctx context.Context, req *pb.StartJourneyRequest) (*pb.Journey, error) {
	j, err := s.db.StartJourney(ctx, req.DeviceId, req.Label)
	if err != nil {
		slog.Error("start journey failed", "err", err)
		return nil, err
	}
	slog.Info("journey started", "id", j.ID, "device", j.DeviceID, "label", j.Label)
	return journeyToProto(j), nil
}

func (s *Server) EndJourney(ctx context.Context, req *pb.EndJourneyRequest) (*pb.Journey, error) {
	j, err := s.db.EndJourney(ctx, req.JourneyId)
	if err != nil {
		slog.Error("end journey failed", "err", err)
		return nil, err
	}
	slog.Info("journey ended", "id", j.ID, "distance", j.TotalDistanceM, "points", j.PointCount)
	return journeyToProto(j), nil
}

func (s *Server) GetJourneys(ctx context.Context, req *pb.GetJourneysRequest) (*pb.GetJourneysResponse, error) {
	limit := req.Limit
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	journeys, total, err := s.db.GetJourneys(ctx, req.DeviceId, limit, req.Offset)
	if err != nil {
		return nil, err
	}
	pbJourneys := make([]*pb.Journey, len(journeys))
	for i, j := range journeys {
		pbJourneys[i] = journeyToProto(j)
	}
	return &pb.GetJourneysResponse{
		Journeys: pbJourneys,
		Total:    total,
	}, nil
}

func (s *Server) GetJourneyPoints(ctx context.Context, req *pb.GetJourneyPointsRequest) (*pb.GetJourneyPointsResponse, error) {
	points, err := s.db.GetJourneyPoints(ctx, req.JourneyId)
	if err != nil {
		return nil, err
	}
	pbPoints := make([]*pb.LocationPoint, len(points))
	for i, p := range points {
		pbPoints[i] = &pb.LocationPoint{
			Latitude:   p.Latitude,
			Longitude:  p.Longitude,
			Accuracy:   p.Accuracy,
			Speed:      p.Speed,
			Altitude:   p.Altitude,
			Heading:    p.Heading,
			RecordedAt: p.RecordedAt.UnixMilli(),
		}
	}
	return &pb.GetJourneyPointsResponse{Points: pbPoints}, nil
}

func (s *Server) StreamLocations(stream pb.LocationService_StreamLocationsServer) error {
	count := 0
	var journeyID string

	for {
		update, err := stream.Recv()
		if err == io.EOF {
			slog.Info("stream ended", "points", count, "journey", journeyID)
			return stream.SendAndClose(&pb.LocationAck{
				PointsReceived: int32(count),
				JourneyId:      journeyID,
			})
		}
		if err != nil {
			slog.Error("stream recv error", "err", err)
			return err
		}

		journeyID = update.JourneyId
		count++

		s.inserter.Submit(db.LocationPoint{
			JourneyID:  update.JourneyId,
			DeviceID:   update.DeviceId,
			Latitude:   update.Latitude,
			Longitude:  update.Longitude,
			Accuracy:   update.Accuracy,
			Speed:      update.Speed,
			Altitude:   update.Altitude,
			Heading:    update.Heading,
			Source:     update.Source,
			RecordedAt: time.UnixMilli(update.TimestampMs),
		})
	}
}

// ============================================================
// Journey Stats
// ============================================================

func (s *Server) GetJourneyStats(ctx context.Context, req *pb.GetJourneyStatsRequest) (*pb.JourneyStats, error) {
	stats, err := s.db.GetJourneyStats(ctx, req.DeviceId, req.Period, int(req.Limit))
	if err != nil {
		return nil, err
	}
	return stats, nil
}

// ============================================================
// Saved Locations
// ============================================================

func (s *Server) SaveLocation(ctx context.Context, req *pb.SaveLocationRequest) (*pb.SavedLocation, error) {
	loc, err := s.db.SaveLocation(ctx, req.DeviceId, req.Name, req.Latitude, req.Longitude, req.RadiusM)
	if err != nil {
		return nil, err
	}
	return loc, nil
}

func (s *Server) GetSavedLocations(ctx context.Context, req *pb.GetSavedLocationsRequest) (*pb.GetSavedLocationsResponse, error) {
	locs, err := s.db.GetSavedLocations(ctx, req.DeviceId)
	if err != nil {
		return nil, err
	}
	return &pb.GetSavedLocationsResponse{Locations: locs}, nil
}

func (s *Server) DeleteSavedLocation(ctx context.Context, req *pb.DeleteSavedLocationRequest) (*pb.Empty, error) {
	err := s.db.DeleteSavedLocation(ctx, req.LocationId)
	if err != nil {
		return nil, err
	}
	return &pb.Empty{}, nil
}

// ============================================================
// Share Links
// ============================================================

func (s *Server) CreateShareLink(ctx context.Context, req *pb.CreateShareLinkRequest) (*pb.ShareLink, error) {
	claims := auth.GetClaims(ctx)
	if claims == nil {
		return nil, fmt.Errorf("unauthenticated")
	}
	link, err := s.db.CreateShareLink(ctx, req.JourneyId, claims.DeviceID, req.DurationHours)
	if err != nil {
		return nil, err
	}
	return link, nil
}

func (s *Server) GetShareLink(ctx context.Context, req *pb.GetShareLinkRequest) (*pb.ShareLink, error) {
	link, err := s.db.GetShareLink(ctx, req.ShareId)
	if err != nil {
		return nil, err
	}
	return link, nil
}

// ============================================================
// Export
// ============================================================

func (s *Server) ExportJourney(ctx context.Context, req *pb.ExportRequest) (*pb.ExportResponse, error) {
	data, filename, err := s.db.ExportJourney(ctx, req.JourneyId, req.Format)
	if err != nil {
		return nil, err
	}
	return &pb.ExportResponse{
		Filename: filename,
		Data:     data,
	}, nil
}

// ============================================================
// Devices
// ============================================================

func (s *Server) GetDevices(ctx context.Context, req *pb.GetDevicesRequest) (*pb.GetDevicesResponse, error) {
	claims := auth.GetClaims(ctx)
	if claims == nil {
		return nil, fmt.Errorf("unauthenticated")
	}
	devices, err := s.auth.GetDevices(ctx, claims.UserID)
	if err != nil {
		return nil, err
	}
	pbDevices := make([]*pb.Device, len(devices))
	for i, d := range devices {
		pbDevices[i] = &pb.Device{
			Id:       d["id"].(string),
			Name:     d["name"].(string),
			Platform: d["platform"].(string),
			LastSeen: d["last_seen"].(int64),
			Active:   d["active"].(bool),
		}
	}
	return &pb.GetDevicesResponse{Devices: pbDevices}, nil
}

// ============================================================
// Helpers
// ============================================================

func journeyToProto(j *db.Journey) *pb.Journey {
	p := &pb.Journey{
		Id:             j.ID,
		DeviceId:       j.DeviceID,
		Label:          j.Label,
		StartedAt:      j.StartedAt.UnixMilli(),
		TotalDistanceM: j.TotalDistanceM,
		PointCount:     j.PointCount,
		TransportMode:  j.TransportMode,
		StartPlace:     j.StartPlace,
		EndPlace:       j.EndPlace,
	}
	if j.EndedAt != nil {
		p.EndedAt = j.EndedAt.UnixMilli()
	}
	return p
}
