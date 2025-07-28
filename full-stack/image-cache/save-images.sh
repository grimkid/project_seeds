#!/bin/bash
# Save all dependent images to tar files for offline caching

set -e

cd "$(dirname "$0")"

docker pull pgvector/pgvector:pg16

docker pull nginx:latest

docker pull amazoncorretto:21

docker pull alpine:latest

docker pull dotcms/dotcms:24.12.27_lts_v8_6031d3b

docker pull grafana/grafana-oss:latest

docker pull grafana/loki:2.9.7

docker pull curlimages/curl:8.7.1

docker pull grafana/promtail:2.9.11
 
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.17.14
 

# Add more images as needed
echo "Saving curlimages/curl:8.7.1 to elastic.tar..."
docker save curlimages/curl:8.7.1 -o curl.tar

echo "Saving docker.elastic.co/elasticsearch/elasticsearch:7.17.14 to elastic.tar..."
docker save docker.elastic.co/elasticsearch/elasticsearch:7.17.14 -o elastic.tar

echo "Saving grafana/promtail:2.9.11 to promtail.tar..."
docker save grafana/promtail:2.9.11 -o promtail.tar

echo "Saving pgvector/pgvector:pg16 to postgres.tar..."
docker save pgvector/pgvector:pg16 -o postgres.tar

echo "Saving nginx:latest to nginx-latest.tar..."
docker save nginx:latest -o nginx-latest.tar

echo "Saving dotcms/dotcms:24.12.27_lts_v8_6031d3b to dotcms.tar..."
docker save dotcms/dotcms:24.12.27_lts_v8_6031d3b -o dotcms.tar

echo "Saving alpine:latest to alpine-latest.tar..."
docker save alpine:latest -o alpine-latest.tar

echo "Saving grafana/grafana-oss:latest to grafana-oss-latest.tar..."
docker save grafana/grafana-oss:latest -o grafana-oss-latest.tar

echo "Saving amazoncorretto:21 to amazoncorretto-21.tar..."
docker save amazoncorretto:21 -o amazoncorretto-21.tar

echo "Saving grafana/loki:2.9.7 to loki-2.9.7.tar..."
docker save grafana/loki:2.9.7 -o loki-2.9.7.tar


echo "Images saved to $(pwd)"
