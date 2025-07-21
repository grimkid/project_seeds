#!/bin/bash
# Clean all Renar stack resources: containers, images, network, and prune Docker

set -e

# Stop and remove containers
for cname in dotcms-postgres dotcms-app grafana-monitoring loki-monitoring frontend-dev-pod backend-dev-pod nginx-server; do
  docker rm -f "$cname" 2>/dev/null || true
done

# Remove custom dotcms-promtail image
if docker images | grep -q dotcms; then
  docker rmi -f dotcms || true
fi

# Remove dotcms-net network
if docker network inspect dotcms-net >/dev/null 2>&1; then
  docker network rm dotcms-net || true
fi

# Prune unused Docker resources (no prompt)
docker system prune -af --volumes

echo "[clean-all] Docker system pruned. All containers, custom images, and network removed. Persistent data folders remain."
