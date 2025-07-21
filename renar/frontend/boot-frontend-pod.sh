#!/bin/bash
# Boot script for frontend dev pod

CONTAINER_NAME="frontend-dev-pod"
IMAGE_NAME="frontend-dev-image"
DATA_DIR="$(dirname "$0")/data"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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
  docker rm -f "$CONTAINER_NAME"
fi

# Load amazoncorretto:21 from image-cache if available
CACHE_DIR="$SCRIPT_DIR/../image-cache"
if [ -f "$CACHE_DIR/amazoncorretto-21.tar" ]; then
  echo "[backend] Loading amazoncorretto:21 from image-cache..."
  docker load -i "$CACHE_DIR/amazoncorretto-21.tar"
fi

docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"

docker run -d \
  --name "$CONTAINER_NAME" \
  --network dotcms-net \
  --restart=always \
  -p 8090:22 \
  -p 8083:8083 \
  -p 8084:8084 \
  -v "$DATA_DIR:/data" \
  "$IMAGE_NAME"
