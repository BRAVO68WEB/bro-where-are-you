package auth

import (
	"context"
	"crypto/rand"
	"fmt"
	"math/big"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

const (
	codeLength   = 5
	codeChars    = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // no I/O/0/1 for readability
	codeExpiry   = 10 * time.Minute
	pollInterval = 5 // seconds
)

type DeviceCodeManager struct {
	pool      *pgxpool.Pool
	jwtSecret []byte
}

type DeviceCode struct {
	DeviceCode string
	DeviceID   string
	DeviceName string
	Platform   string
	ExpiresAt  time.Time
}

type DeviceActivation struct {
	Activated   bool
	DeviceToken string
	DeviceID    string
	DeviceName  string
}

func NewDeviceCodeManager(pool *pgxpool.Pool, jwtSecret string) *DeviceCodeManager {
	return &DeviceCodeManager{
		pool:      pool,
		jwtSecret: []byte(jwtSecret),
	}
}

// GenerateCode creates a new device code for pairing.
func (m *DeviceCodeManager) GenerateCode(ctx context.Context, deviceName, platform string) (*DeviceCode, error) {
	code, err := generateCode()
	if err != nil {
		return nil, fmt.Errorf("generate code: %w", err)
	}

	deviceID := uuid.New()

	_, err = m.pool.Exec(ctx,
		`INSERT INTO device_codes (device_code, device_id, device_name, platform, status, expires_at)
		 VALUES ($1, $2, $3, $4, 'pending', now() + interval '10 minutes')
		 ON CONFLICT (device_code) DO UPDATE SET
		   device_id = EXCLUDED.device_id,
		   device_name = EXCLUDED.device_name,
		   platform = EXCLUDED.platform,
		   status = 'pending',
		   expires_at = now() + interval '10 minutes',
		   device_token = NULL,
		   activated_at = NULL`,
		code, deviceID, deviceName, platform,
	)
	if err != nil {
		return nil, fmt.Errorf("insert device code: %w", err)
	}

	return &DeviceCode{
		DeviceCode: code,
		DeviceID:   deviceID.String(),
		DeviceName: deviceName,
		Platform:   platform,
		ExpiresAt:  time.Now().Add(codeExpiry),
	}, nil
}

// Poll checks if a device code has been activated.
func (m *DeviceCodeManager) Poll(ctx context.Context, code string) (*DeviceActivation, error) {
	var status, deviceID, deviceName string
	var deviceToken *string

	err := m.pool.QueryRow(ctx,
		`SELECT status, device_id::text, device_name, device_token
		 FROM device_codes WHERE device_code = $1`, code,
	).Scan(&status, &deviceID, &deviceName, &deviceToken)
	if err != nil {
		return &DeviceActivation{Activated: false}, nil
	}

	if status == "activated" && deviceToken != nil {
		return &DeviceActivation{
			Activated:   true,
			DeviceToken: *deviceToken,
			DeviceID:    deviceID,
			DeviceName:  deviceName,
		}, nil
	}

	return &DeviceActivation{Activated: false}, nil
}

// Activate is called from the web portal to activate a device code.
func (m *DeviceCodeManager) Activate(ctx context.Context, code, userID string) (*DeviceActivation, error) {
	// Get the pending device code
	var deviceID, deviceName, platform string
	var expiresAt time.Time

	err := m.pool.QueryRow(ctx,
		`SELECT device_id::text, device_name, platform, expires_at
		 FROM device_codes
		 WHERE device_code = $1 AND status = 'pending'`, code,
	).Scan(&deviceID, &deviceName, &platform, &expiresAt)
	if err != nil {
		return nil, fmt.Errorf("invalid or expired device code")
	}

	if time.Now().After(expiresAt) {
		// Mark as expired
		_, _ = m.pool.Exec(ctx, `UPDATE device_codes SET status = 'expired' WHERE device_code = $1`, code)
		return nil, fmt.Errorf("device code has expired")
	}

	// Generate JWT
	token, err := m.generateJWT(deviceID, userID, deviceName, platform)
	if err != nil {
		return nil, fmt.Errorf("generate jwt: %w", err)
	}

	// Update device code as activated
	_, err = m.pool.Exec(ctx,
		`UPDATE device_codes
		 SET status = 'activated', device_token = $1, user_id = $2, activated_at = now()
		 WHERE device_code = $3`,
		token, userID, code,
	)
	if err != nil {
		return nil, fmt.Errorf("update device code: %w", err)
	}

	// Register device
	_, err = m.pool.Exec(ctx,
		`INSERT INTO devices (id, user_id, name, platform, last_seen, active)
		 VALUES ($1, $2, $3, $4, now(), true)
		 ON CONFLICT (id) DO UPDATE SET
		   user_id = EXCLUDED.user_id,
		   name = EXCLUDED.name,
		   last_seen = now(),
		   active = true`,
		deviceID, userID, deviceName, platform,
	)
	if err != nil {
		return nil, fmt.Errorf("register device: %w", err)
	}

	return &DeviceActivation{
		Activated:   true,
		DeviceToken: token,
		DeviceID:    deviceID,
		DeviceName:  deviceName,
	}, nil
}

// ValidateToken validates a JWT and returns claims.
func (m *DeviceCodeManager) ValidateToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return m.jwtSecret, nil
	})
	if err != nil {
		return nil, fmt.Errorf("parse token: %w", err)
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, fmt.Errorf("invalid token")
	}

	return claims, nil
}

type Claims struct {
	DeviceID   string `json:"device_id"`
	UserID     string `json:"user_id"`
	DeviceName string `json:"device_name"`
	Platform   string `json:"platform"`
	jwt.RegisteredClaims
}

func (m *DeviceCodeManager) generateJWT(deviceID, userID, deviceName, platform string) (string, error) {
	claims := &Claims{
		DeviceID:   deviceID,
		UserID:     userID,
		DeviceName: deviceName,
		Platform:   platform,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(365 * 24 * time.Hour)), // 1 year
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "bwhere",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(m.jwtSecret)
}

// GetDevices returns all devices for a user.
func (m *DeviceCodeManager) GetDevices(ctx context.Context, userID string) ([]map[string]interface{}, error) {
	rows, err := m.pool.Query(ctx,
		`SELECT id::text, name, platform, last_seen, active
		 FROM devices WHERE user_id = $1 ORDER BY last_seen DESC`, userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var devices []map[string]interface{}
	for rows.Next() {
		var id, name, platform string
		var lastSeen time.Time
		var active bool
		if err := rows.Scan(&id, &name, &platform, &lastSeen, &active); err != nil {
			return nil, err
		}
		devices = append(devices, map[string]interface{}{
			"id":        id,
			"name":      name,
			"platform":  platform,
			"last_seen": lastSeen.Unix(),
			"active":    active,
		})
	}
	return devices, nil
}

func generateCode() (string, error) {
	code := make([]byte, codeLength)
	max := big.NewInt(int64(len(codeChars)))
	for i := range code {
		n, err := rand.Int(rand.Reader, max)
		if err != nil {
			return "", err
		}
		code[i] = codeChars[n.Int64()]
	}
	return string(code), nil
}
