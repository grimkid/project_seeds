#!/bin/bash
# Boot the entire Renar stack in the correct order
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "[boot-all] Starting boot process in $SCRIPT_DIR"


# 0. Initialize internal Docker network
cd "$SCRIPT_DIR/docker-network"
chmod +x init-internal-network.sh
./init-internal-network.sh
cd "$SCRIPT_DIR"



# 1. Start Nginx
cd "$SCRIPT_DIR/nginx"
chmod +x start-nginx.sh
cd "$SCRIPT_DIR"
echo "[boot-all] Starting Nginx..."
./nginx/start-nginx.sh

# 2. Start dotCMS and Postgres
cd "$SCRIPT_DIR/dotcms"
chmod +x boot-dotcms.sh
chmod +x entrypoint-dotcms-promtail.sh || true
cd "$SCRIPT_DIR"

echo "[boot-all] Starting dotCMS and Postgres..."
./dotcms/boot-dotcms.sh 


# Wait for dotCMS to be up (via nginx reverse proxy) with progress log and status code
echo "[boot-all] Waiting for dotCMS to be healthy via nginx..."
dotcms_retries=60
while true; do
  status=$(curl -sk -o /dev/null -w "%{http_code}" http://localhost:8089/dotcms/)
  if [ "$status" = "200" ]; then
    echo "[boot-all] dotCMS is healthy (HTTP 200)."
    break
  else
    echo -ne "[boot-all] dotCMS not ready yet (HTTP $status), retries left: $dotcms_retries\r"
  fi
  dotcms_retries=$((dotcms_retries-1))
  if [ $dotcms_retries -le 0 ]; then
    echo
    echo "[boot-all] ERROR: dotCMS did not become healthy in time. Last HTTP status: $status"
    # Print last 10 lines of nginx error log for debugging
    if [ -f "$SCRIPT_DIR/nginx/data/log/error.log" ]; then
      echo "[boot-all] Last 10 lines of nginx error log:"
      tail -n 10 "$SCRIPT_DIR/nginx/data/log/error.log"
    fi
    exit 1
  fi
  sleep 3
done


# 3. Start Loki
cd "$SCRIPT_DIR/monitoring"
chmod +x boot-loki.sh
cd "$SCRIPT_DIR"
echo "[boot-all] Starting Loki..."
./monitoring/boot-loki.sh

# 4. Start Grafana
cd "$SCRIPT_DIR/monitoring"
chmod +x boot-grafana.sh
cd "$SCRIPT_DIR"
./monitoring/boot-grafana.sh &


# Wait for Grafana to be up (via nginx reverse proxy) with countdown
echo "[boot-all] Waiting for Grafana to be healthy via nginx..."
grafana_retries=60
until curl -sf http://localhost:8089/grafana/api/health | grep -q 'database'; do
  grafana_retries=$((grafana_retries-1))
  if [ $grafana_retries -le 0 ]; then
    echo "[boot-all] ERROR: Grafana did not become healthy in time."
    exit 1
  fi
  sleep 3
done


# 5. Start frontend pod
cd "$SCRIPT_DIR/frontend"
chmod +x boot-frontend-pod.sh
cd "$SCRIPT_DIR"
echo "[boot-all] Starting frontend pod..."
./frontend/boot-frontend-pod.sh

# 6. Start backend pod
cd "$SCRIPT_DIR/backend"
chmod +x boot-backend-pod.sh
cd "$SCRIPT_DIR"
echo "[boot-all] Starting backend pod..."
./backend/boot-backend-pod.sh

echo "[boot-all] All services started."
