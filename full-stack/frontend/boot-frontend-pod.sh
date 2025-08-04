#!/bin/bash
# Boot script for frontend dev pod

CONTAINER_NAME="frontend-dev-pod"
IMAGE_NAME="frontend-dev-image"
DATA_DIR="$(dirname "$0")/data"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CODE_DIR="$SCRIPT_DIR/frontend-platform"

# Ensure data directory exists and set permissions/ownership
if [ ! -d "$DATA_DIR" ]; then
  mkdir -p "$DATA_DIR"
fi
sudo chown -R 1000:1000 "$DATA_DIR"
chmod -R 777 "$DATA_DIR"

# Check for Dockerfile before build
if [ ! -f "$SCRIPT_DIR/Dockerfile" ]; then
  echo "[ERROR] Dockerfile not found in $SCRIPT_DIR. Aborting frontend build."
  exit 1
fi

# Remove container if exists
if docker inspect "$CONTAINER_NAME" > /dev/null 2>&1; then
  echo "Se șterge containerul vechi: $CONTAINER_NAME"
  docker rm -f "$CONTAINER_NAME"
fi

CACHE_DIR="$SCRIPT_DIR/../image-cache"
if [ -f "$CACHE_DIR/node20bullseye.tar" ]; then
  echo "[backend] Loading node:20-bullseye from image-cache..."
  docker load -i "$CACHE_DIR/node20bullseye.tar"
fi

# Build a fresh image
echo "Se construiește imaginea $IMAGE_NAME..."
docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"

# Run the container with correct parameters
echo "Se pornește containerul $CONTAINER_NAME..."
docker run -d \
  --name "$CONTAINER_NAME" \
  --network internal-net \
  --restart=always \
  -p 8090:22 \
  -p 3000:3000 \
  -v "$DATA_DIR:/data" \
  -v "$CODE_DIR:/app" \
  "$IMAGE_NAME"

echo "Containerul a fost pornit. Verifică log-urile cu: docker logs -f $CONTAINER_NAME"