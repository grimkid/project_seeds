#!/bin/bash
# Boot script for Loki log aggregation

CONTAINER_NAME="loki-monitoring"
IMAGE_NAME="grafana/loki:2.9.7"
DATA_DIR="$(dirname "$0")/data-loki"
CONFIG_FILE="$(dirname "$0")/loki-config.yaml"

# Ensure all required subdirectories exist and set permissions/ownership
for d in chunks rules index boltdb-cache rules-temp wal compactor; do
  mkdir -p "$DATA_DIR/$d"
  sudo chown -R 10001:10001 "$DATA_DIR/$d"
  chmod -R 777 "$DATA_DIR/$d"
done
chmod -R 777 "$DATA_DIR"

# Remove container if exists
if docker inspect "$CONTAINER_NAME" > /dev/null 2>&1; then
  docker rm -f "$CONTAINER_NAME"
fi

# Load grafana/loki:2.9.7 from image-cache if available
CACHE_DIR="$(dirname "$0")/../image-cache"
if [ -f "$CACHE_DIR/loki-2.9.7.tar" ]; then
  echo "[loki] Loading grafana/loki:2.9.7 from image-cache..."
  docker load -i "$CACHE_DIR/loki-2.9.7.tar"
fi

docker run -d \
  --name "$CONTAINER_NAME" \
  --network dotcms-net \
  --restart=always \
  -p 8088:3100 \
  -v "$DATA_DIR:/loki" \
  -v "$CONFIG_FILE:/etc/loki/loki-config.yaml" \
  "$IMAGE_NAME" \
  -config.file=/etc/loki/loki-config.yaml
