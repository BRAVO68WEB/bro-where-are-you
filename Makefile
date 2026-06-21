.PHONY: proto server run docker-up docker-down docker-logs clean valhalla-up valhalla-down

# Proto codegen (run from server/ directory)
proto:
	cd server && protoc --go_out=. --go_opt=module=bwhere \
		--go-grpc_out=. --go-grpc_opt=module=bwhere \
		../proto/location/v1/location.proto

# Go server
server:
	cd server && go build -o ../bin/server ./cmd/server

run: server
	./bin/server

# Docker (local dev)
docker-up:
	docker compose up -d --build

docker-down:
	docker compose down

docker-logs:
	docker compose logs -f

# Clean
clean:
	rm -rf bin/

# Valhalla (optional snap-to-road routing)
valhalla-up:
	LOAD_VALHALLA=true VALHALLA_URL=http://valhalla:8002 \
		docker compose --profile valhalla up -d --build

valhalla-down:
	docker compose --profile valhalla down
