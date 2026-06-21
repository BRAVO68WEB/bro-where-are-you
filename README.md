# Bro Where Are You (bwhere)

A self-hosted location tracking and journey recording platform. Track your daily commutes, replay routes on a map, view heatmaps of your movement, and get push notifications for journey events.

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Flutter    │────▶│  Go Server   │────▶│  PostgreSQL  │
│  Mobile App  │gRPC │  gRPC + HTTP │     │  + PostGIS   │
└──────────────┘     └──────┬───────┘     └──────┬───────┘
                            │                     │
┌──────────────┐     ┌──────▼───────┐     ┌──────▼───────┐
│  React SPA   │────▶│   Hasura     │────▶│  PostgreSQL  │
│  (Vite)      │ GQL │  GraphQL     │     │  (shared)    │
└──────────────┘     └──────────────┘     └──────────────┘
```

## Features

- **Real-time GPS streaming** via gRPC client-streaming from mobile devices
- **Journey recording** with start/stop, distance calculation, transport mode tagging
- **Journey replay** on interactive maps with speed and elevation profiles
- **Heatmap visualization** of location density over time
- **Multi-device tracking** — track multiple phones/watches from one dashboard
- **Geofencing** — save locations and get enter/exit push notifications
- **Share links** — generate expiring links to share journeys with others
- **Export** — download journeys as GPX, GeoJSON, or CSV
- **Daily summaries** — automated push notification with your stats
- **PWA support** — install the web app on your phone's home screen
- **WearOS companion** — smartwatch app for quick journey controls
- **Dark/light theme** with a ClickHouse-inspired design system

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Go 1.25 (gRPC + Gin HTTP) |
| Database | PostgreSQL 16 + PostGIS 3.4 |
| GraphQL | Hasura v2.44.0 |
| Web Frontend | React 18, TypeScript, Vite, Leaflet |
| Mobile | Flutter (Android + WearOS) |
| Push Notifications | OneSignal |
| Auth | OIDC (web) + Device Code Flow (mobile) |
| Routing (optional) | Valhalla snap-to-road |

## Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- An OIDC provider (e.g., [Authelia](https://www.authelia.com/), [Keycloak](https://www.keycloak.org/), [Auth0](https://auth0.com/))
- (Optional) [OneSignal](https://onesignal.com/) account for push notifications

### 1. Clone and configure

```bash
git clone https://github.com/YOUR_USERNAME/bro-where-are-you.git
cd bro-where-are-you
cp .env.example .env
```

### 2. Edit `.env`

Fill in all required values:

```bash
# Required — change these!
DB_PASSWORD=your-strong-password
HASURA_ADMIN_SECRET=your-hasura-secret
HASURA_WEBHOOK_SECRET=your-webhook-secret
API_KEY=your-api-key
JWT_SECRET=your-jwt-secret-at-least-32-chars

# Required — your OIDC provider
OIDC_JWKS_URL=https://your-provider/.well-known/jwks.json
VITE_OIDC_AUTHORITY=https://your-provider/oidc
VITE_OIDC_CLIENT_ID=your-client-id

# Optional — OneSignal
ONESIGNAL_APP_ID=your-app-id
ONESIGNAL_API_KEY=your-rest-api-key
ONESIGNAL_SAFARI_WEB_ID=web.onesignal.auto.your-id
```

### 3. Start everything

```bash
docker compose up -d --build
```

This starts:

| Service | Internal Port | Description |
|---|---|---|
| `postgres` | 5432 | PostGIS database |
| `hasura` | 8080 | GraphQL engine + console |
| `go-server` | 50051, 8088 | gRPC + REST API |
| `web-app` | 3000 | React SPA |

### 4. Access

- **Web Dashboard**: http://localhost:3000
- **Hasura Console**: http://localhost:8080/console
- **API Health**: http://localhost:8088/health

## Configuration Reference

### Environment Variables

| Variable | Required | Description |
|---|---|---|
| `DB_PASSWORD` | Yes | PostgreSQL password |
| `POSTGRES_DB` | No | Database name (default: `bwhere`) |
| `POSTGRES_USER` | No | Database user (default: `bwhere`) |
| `HASURA_ADMIN_SECRET` | Yes | Hasura admin password |
| `HASURA_WEBHOOK_SECRET` | Yes | Shared secret for Hasura event triggers |
| `API_KEY` | Yes | API key for server endpoints |
| `JWT_SECRET` | Yes | HMAC secret for JWT signing (min 32 chars) |
| `OIDC_JWKS_URL` | Yes | OIDC provider's JWKS endpoint URL |
| `ONESIGNAL_APP_ID` | No | OneSignal app ID |
| `ONESIGNAL_API_KEY` | No | OneSignal REST API key |
| `ONESIGNAL_SAFARI_WEB_ID` | No | OneSignal Safari web ID |
| `VALHALLA_URL` | No | Valhalla routing service URL |

### Vite (Web Frontend) Variables

| Variable | Required | Description |
|---|---|---|
| `VITE_HASURA_URL` | No | Hasura GraphQL endpoint (default: `http://localhost:8080/v1/graphql`) |
| `VITE_HASURA_ADMIN_SECRET` | No | Hasura admin secret (for dev only) |
| `VITE_API_URL` | No | Go server API URL (default: `http://localhost:8088`) |
| `VITE_OIDC_AUTHORITY` | Yes | OIDC provider authority URL |
| `VITE_OIDC_CLIENT_ID` | Yes | OIDC client ID |
| `VITE_OIDC_REDIRECT_URI` | No | OIDC callback URL (default: `http://localhost:3000/callback`) |
| `VITE_ONESIGNAL_APP_ID` | No | OneSignal app ID for web push |
| `VITE_ONESIGNAL_SAFARI_WEB_ID` | No | OneSignal Safari web ID |

## Development

### Local dev with hot reload

The `docker-compose.override.yml` is loaded automatically and exposes all ports to localhost with hot reload for the web frontend.

```bash
# Start in dev mode (auto-loads override)
docker compose up -d --build

# Run the web frontend locally for faster iteration
cd web
cp .env.example .env  # edit as needed
npm install
npm run dev
```

### Production (no override)

```bash
docker compose -f docker-compose.yml up -d --build
```

### Proto codegen

```bash
make proto
```

### Build Go server locally

```bash
make server
make run
```

## Mobile App (Flutter)

### Prerequisites

- Flutter SDK 3.7+
- Android Studio / Xcode

### Setup

```bash
cd mobile
flutter pub get
flutter run
```

The mobile app connects to the gRPC server. On first launch, enter your server host and port in the auth screen. The app uses a device code flow — it generates a code, you approve it from the web dashboard's Devices page.

### WearOS

```bash
cd mobile/wear
flutter pub get
flutter run
```

## Optional Services

### Valhalla (Snap-to-Road)

Corrects GPS drift by snapping recorded points to the road network.

```bash
# 1. Download OSM data for your region
mkdir -p valhalla
wget https://download.geofabrik.de/your-region-latest.osm.pbf -O valhalla/region.osm.pbf

# 2. Add to docker-compose.yml (see docker-compose.valhalla.yml for reference)
# 3. Set VALHALLA_URL=http://valhalla:8002 in .env
# 4. Restart
docker compose up -d
```

See `docker-compose.valhalla.yml` for the full service definition.

### Cloudflare Tunnel

Expose your local services to the internet securely.

1. Install [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
2. Copy `cloudflared/config.yml` and update the tunnel UUID and hostnames
3. Place `credentials.json` in the `cloudflared/` directory
4. Run alongside docker compose:

```bash
docker run --network=host -v ./cloudflared:/etc/cloudflared cloudflare/cloudflared tunnel run
```

## API Overview

### gRPC (port 50051)

The `LocationService` proto defines all RPCs:

| RPC | Description |
|---|---|
| `StreamLocations` | Client-streaming GPS updates |
| `StartJourney` / `EndJourney` | Journey lifecycle |
| `GetJourneys` / `GetJourneyPoints` | Query journey history |
| `RequestDeviceCode` / `PollDeviceActivation` | Device auth flow |
| `SaveLocation` / `GetSavedLocations` / `DeleteSavedLocation` | Geofence management |
| `CreateShareLink` / `GetShareLink` | Journey sharing |
| `ExportJourney` | GPX/GeoJSON/CSV export |
| `GetDevices` | List paired devices |
| `GetJourneyStats` | Aggregated statistics |

See `proto/location/v1/location.proto` for the full schema.

### REST (port 8088)

| Endpoint | Method | Description |
|---|---|---|
| `/health` | GET | Health check |
| `/auth/activate` | POST | Activate device with code |
| `/api/export?journey_id=X&format=Y` | GET | Export journey |
| `/api/share` | POST | Create share link |
| `/api/share/:id` | GET | Get share link |
| `/api/notifications/test` | POST | Send test notification |
| `/api/webhooks/hasura` | POST | Hasura event trigger |

### GraphQL (port 8080)

Hasura auto-generates a GraphQL API over the Postgres schema with real-time subscriptions. Access the console at `http://localhost:8080/console`.

## Project Structure

```
.
├── docker-compose.yml          # Production services
├── docker-compose.override.yml # Dev overrides (auto-loaded)
├── docker-compose.valhalla.yml # Optional routing service
├── .env.example                # Environment template
├── Makefile                    # Build automation
├── proto/                      # Protobuf definitions
├── server/                     # Go backend (gRPC + HTTP)
│   ├── cmd/server/             # Entry point
│   ├── internal/               # Business logic
│   ├── migrations/             # DB migrations
│   └── pb/                     # Generated protobuf code
├── web/                        # React SPA
│   ├── src/
│   │   ├── auth/               # OIDC config
│   │   ├── components/         # UI components
│   │   ├── pages/              # Route pages
│   │   ├── graphql/            # GraphQL client + subscriptions
│   │   └── lib/                # Utilities (OneSignal, etc.)
│   └── Dockerfile
├── mobile/                     # Flutter Android app
│   ├── lib/                    # Dart source
│   └── wear/                   # WearOS companion
└── hasura/                # Hasura metadata + config
```

## License

MIT
