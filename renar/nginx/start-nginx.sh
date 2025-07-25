#!/bin/bash
# Start the Nginx container using the Dockerfile in this directory

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
 # Remove existing nginx-server container if it exists
 docker rm -f nginx-server 2>/dev/null || true

# Load grafana/loki:2.9.7 from image-cache if available
CACHE_DIR="$(dirname "$0")/../image-cache"
if [ -f "$CACHE_DIR/nginx-latest.tar" ]; then
  echo "[loki] Loading nginx:alpine from image-cache..."
  docker load -i "$CACHE_DIR/nginx-latest.tar"
fi

docker build -t custom-nginx .
docker run -d \
  --restart=always \
  --network=internal-net \
  --ip=172.28.0.10 \
  -p 8089:80 \
  --name nginx-server \
  --add-host=host.docker.internal:host-gateway \
  -v "$SCRIPT_DIR/data/html:/usr/share/nginx/html" \
  -v "$SCRIPT_DIR/data/log:/var/log/nginx" \
  custom-nginx

echo "Nginx is running at http://localhost:8089"
