#!/bin/bash
# Boot script for Grafana monitoring

CONTAINER_NAME="grafana-monitoring"
IMAGE_NAME="grafana/grafana-oss:latest"
DATA_DIR="$(dirname "$0")/data"
PROVISION_FILE="$(dirname "$0")/grafana-provision-loki.yaml"
GRAFANA_ADMIN_PASS="e2f1c3b4-5d6e-7f8a-9b0c-1d2e3f4a5b6c"  # Hardcoded UUID
USERS=(rares seby user)

# Ensure data directory exists (recreate if missing) and set correct permissions/ownership
if [ ! -d "$DATA_DIR" ]; then
  mkdir -p "$DATA_DIR"
fi
sudo chown -R 472:472 "$DATA_DIR"
chmod -R 777 "$DATA_DIR"

# Remove container if exists
if docker inspect "$CONTAINER_NAME" > /dev/null 2>&1; then
  docker rm -f "$CONTAINER_NAME"
fi

# Load grafana/loki:2.9.7 from image-cache if available
CACHE_DIR="$(dirname "$0")/../image-cache"
if [ -f "$CACHE_DIR/grafana-oss-latest.tar" ]; then
  echo "[loki] Loading grafana-oss-latest from image-cache..."
  docker load -i "$CACHE_DIR/grafana-oss-latest.tar"
fi 

docker run -d \
  --name "$CONTAINER_NAME" \
  --network internal-net \
  --ip 172.28.0.20 \
  --restart=always \
  -v "$DATA_DIR:/var/lib/grafana" \
  -v "$PROVISION_FILE:/etc/grafana/provisioning/datasources/grafana-provision-loki.yaml" \
  -e GF_SECURITY_ADMIN_USER=admin \
  -e GF_SECURITY_ADMIN_PASSWORD="$GRAFANA_ADMIN_PASS" \
  -e GF_SERVER_ROOT_URL="http://localhost:8089/grafana/" \
  "$IMAGE_NAME"

# Wait for Grafana to be up (via nginx reverse proxy)
until curl -s http://localhost:8089/grafana/api/health | grep -q 'database'; do
  echo "[grafana] Waiting for Grafana to be ready via nginx..."
  sleep 3
done

# Create users with admin role
for user in "${USERS[@]}"; do
  pass="${user}admin"
  email="${user}@local.com"
  echo "[grafana] Creating user $user..."
  # Check if user exists (via nginx reverse proxy)
  user_id=$(curl -s -u admin:$GRAFANA_ADMIN_PASS http://localhost:8089/grafana/api/users/lookup?loginOrEmail=$user | grep -o '"id":[0-9]*' | head -n1 | cut -d':' -f2)
  if [ -z "$user_id" ]; then
    # Create user if not exists
    curl -s -X POST http://localhost:8089/grafana/api/admin/users \
      -H "Content-Type: application/json" \
      -u admin:$GRAFANA_ADMIN_PASS \
      -d '{"name":"'$user'","email":"'$email'","login":"'$user'","password":"'$pass'","OrgId":1}' >/dev/null
    # Get new user id
    user_id=$(curl -s -u admin:$GRAFANA_ADMIN_PASS http://localhost:8089/grafana/api/users/lookup?loginOrEmail=$user | grep -o '"id":[0-9]*' | head -n1 | cut -d':' -f2)
  fi
  # Make user admin if user_id found
  if [ -n "$user_id" ]; then
    curl -s -X PATCH http://localhost:8089/grafana/api/orgs/1/users/$user_id \
      -H "Content-Type: application/json" \
      -u admin:$GRAFANA_ADMIN_PASS \
      -d '{"role":"Admin"}' >/dev/null
  fi
done
