package auth

import (
	"context"
	"log/slog"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

type contextKey string

const (
	ClaimsKey contextKey = "auth_claims"
)

// Interceptor returns a unary + stream interceptor that validates JWT tokens.
// Auth-exempt RPCs (device code flow, health check) skip validation.
func Interceptor(dcm *DeviceCodeManager) (grpc.UnaryServerInterceptor, grpc.StreamServerInterceptor) {
	unary := func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		if isExempt(info.FullMethod) {
			return handler(ctx, req)
		}
		claims, err := validateFromContext(ctx, dcm)
		if err != nil {
			return nil, err
		}
		ctx = context.WithValue(ctx, ClaimsKey, claims)
		return handler(ctx, req)
	}

	stream := func(srv any, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		if isExempt(info.FullMethod) {
			return handler(srv, ss)
		}
		claims, err := validateFromContext(ss.Context(), dcm)
		if err != nil {
			return err
		}
		wrapped := &wrappedStream{ServerStream: ss, ctx: context.WithValue(ss.Context(), ClaimsKey, claims)}
		return handler(srv, wrapped)
	}

	return unary, stream
}

// isExempt returns true for RPCs that don't require auth.
func isExempt(method string) bool {
	exempt := []string{
		"/location.v1.LocationService/RequestDeviceCode",
		"/location.v1.LocationService/PollDeviceActivation",
		"/location.v1.LocationService/GetShareLink",
		"/grpc.reflection.v1.ServerReflection/ServerReflectionInfo",
		"/grpc.reflection.v1alpha.ServerReflection/ServerReflectionInfo",
	}
	for _, e := range exempt {
		if method == e {
			return true
		}
	}
	return false
}

func validateFromContext(ctx context.Context, dcm *DeviceCodeManager) (*Claims, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "missing metadata")
	}

	authHeader := md.Get("authorization")
	if len(authHeader) == 0 {
		return nil, status.Error(codes.Unauthenticated, "missing authorization header")
	}

	token := strings.TrimPrefix(authHeader[0], "Bearer ")
	if token == authHeader[0] {
		// No "Bearer " prefix — try raw token
		token = authHeader[0]
	}

	claims, err := dcm.ValidateToken(token)
	if err != nil {
		slog.Debug("auth failed", "err", err)
		return nil, status.Error(codes.Unauthenticated, "invalid token")
	}

	return claims, nil
}

// GetClaims extracts auth claims from context.
func GetClaims(ctx context.Context) *Claims {
	claims, _ := ctx.Value(ClaimsKey).(*Claims)
	return claims
}

type wrappedStream struct {
	grpc.ServerStream
	ctx context.Context
}

func (w *wrappedStream) Context() context.Context {
	return w.ctx
}
