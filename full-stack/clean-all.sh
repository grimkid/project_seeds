#!/bin/bash
# Clean all full-stack resources: containers, images, network, and prune Docker

set -e

# Stop and remove containers
for cname in dotcms-postgres dotcms-app grafana-monitoring loki-monitoring frontend-dev-pod backend-dev-pod nginx-server; do
  docker rm -f "$cname" 2>/dev/null || true
done

# Remove custom dotcms-promtail image
if docker images | grep -q dotcms; then
  docker rmi -f dotcms || true
fi

# Remove dotcms-net and internal-net networks
if docker network inspect dotcms-net >/dev/null 2>&1; then
  docker network rm dotcms-net || true
fi
if docker network inspect internal-net >/dev/null 2>&1; then
  docker network rm internal-net || true
fi

# Prune unused Docker resources (no prompt)
docker system prune -af --volumes

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Remove data directories
rm -rf "$SCRIPT_DIR/dotcms/data/postgres"/*
rm -rf "$SCRIPT_DIR/dotcms/data/dotcms"/*
rm -rf "$SCRIPT_DIR/dotcms/data/dotcms/logs"/*
rm -rf "$SCRIPT_DIR/dotcms/data/dotcms/shared"/*

# Remove Docker volumes related to dotcms and postgres
for volume in $(docker volume ls -q | grep -E 'dotcms|postgres'); do
  echo "Removing Docker volume: $volume"
  docker volume rm "$volume"
done

echo "[clean-all] Docker system pruned. All containers, custom images, and network removed. Persistent data folders remain."
echo "All relevant data directories and Docker volumes have been cleaned."
