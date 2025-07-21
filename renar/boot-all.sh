#!/bin/bash
# Boot the entire Renar stack in the correct order
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "[boot-all] Starting boot process in $SCRIPT_DIR"
# 1. Start dotCMS and Postgres
cd "$SCRIPT_DIR/dotcms"
chmod +x boot-dotcms.sh
chmod +x entrypoint-dotcms-promtail.sh || true
cd "$SCRIPT_DIR"

echo "[boot-all] Starting dotCMS and Postgres..."
./dotcms/boot-dotcms.sh &

# Wait for dotCMS to be up (port 8086)
echo "[boot-all] Waiting for dotCMS to be up on port 8086..."
while ! nc -z localhost 8086; do
  sleep 3
done

# 2. Start Loki
cd "$SCRIPT_DIR/monitoring"
chmod +x boot-loki.sh
cd "$SCRIPT_DIR"
echo "[boot-all] Starting Loki..."
./monitoring/boot-loki.sh

# 3. Start Grafana
cd "$SCRIPT_DIR/monitoring"
chmod +x boot-grafana.sh
cd "$SCRIPT_DIR"
./monitoring/boot-grafana.sh &

# Wait for Grafana to be up (port 8087)
echo "[boot-all] Waiting for Grafana to be up on port 8087..."
while ! nc -z localhost 8087; do
  sleep 3
done

# 4. Start frontend pod
cd "$SCRIPT_DIR/frontend"
chmod +x boot-frontend-pod.sh
cd "$SCRIPT_DIR"
echo "[boot-all] Starting frontend pod..."
./frontend/boot-frontend-pod.sh

# 5. Start backend pod
cd "$SCRIPT_DIR/backend"
chmod +x boot-backend-pod.sh
cd "$SCRIPT_DIR"
echo "[boot-all] Starting backend pod..."
./backend/boot-backend-pod.sh

# 6. Start Nginx
cd "$SCRIPT_DIR/nginx"
chmod +x start-nginx.sh
cd "$SCRIPT_DIR"
echo "[boot-all] Starting Nginx..."
./nginx/start-nginx.sh

echo "[boot-all] All services started."
