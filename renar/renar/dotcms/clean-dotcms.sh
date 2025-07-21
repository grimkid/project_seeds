#!/bin/bash
# Script to stop and remove all dotCMS-related containers and images

set -e


# Add Elasticsearch container and image
CONTAINERS=(dotcms-app dotcms-postgres promtail-dotcms dotcms-elasticsearch)
IMAGES=(dotcms/dotcms:24.12.27_lts_v8_6031d3b postgres:15 grafana/promtail:2.9.11 docker.elastic.co/elasticsearch/elasticsearch:8.5.3)

for cname in "${CONTAINERS[@]}"; do
  if docker ps -a --format '{{.Names}}' | grep -q "^$cname$"; then
    echo "Stopping and removing container: $cname"
    docker rm -f "$cname"
  fi
done

for img in "${IMAGES[@]}"; do
  if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$img"; then
    echo "Removing image: $img"
    docker rmi -f "$img"
  fi
done

echo "[clean-dotcms] Done."
