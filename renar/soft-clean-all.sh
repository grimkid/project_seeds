#!/bin/bash
# Soft clean: remove all Renar stack containers, custom images, and networks, but KEEP persistent data

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
docker system prune -af

echo "[soft-clean-all] Docker system pruned. All containers, custom images, and networks removed."
echo "Persistent data directories and Docker volumes have been preserved."
