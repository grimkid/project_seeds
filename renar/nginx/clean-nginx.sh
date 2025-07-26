#!/bin/bash
# Script to stop and remove the Nginx container and image, but keep persistent data (default config and html)

set -e

CONTAINER_NAME="nginx-server"
IMAGE_NAME="custom-nginx"

# Stop and remove the Nginx container if it exists
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "Stopping and removing container: $CONTAINER_NAME"
  docker rm -f "$CONTAINER_NAME"
fi

# Remove the custom Nginx image if it exists
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$IMAGE_NAME:latest$"; then
  echo "Removing image: $IMAGE_NAME:latest"
  docker rmi -f "$IMAGE_NAME:latest"
fi

echo "[clean-nginx] Done. Persistent data and config are preserved."
