#!/bin/bash
# Boot script for dotCMS pod with Promtail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$SCRIPT_DIR/data/dotcms"
mkdir -p "$SCRIPT_DIR/data/dotcms/logs"
mkdir -p "$SCRIPT_DIR/data/postgres"
mkdir -p "$SCRIPT_DIR/data/dotcms/shared" 

docker rm -f dotcms-app dotcms-postgres promtail-dotcms 2>/dev/null || true

# Set permissions for dotcms and postgres data directories
sudo chown -R 10001:10001 "$SCRIPT_DIR/data/dotcms"
sudo chmod -R 777 "$SCRIPT_DIR/data/dotcms"
sudo chown -R 10001:10001 "$SCRIPT_DIR/data/dotcms/logs"
sudo chmod -R 777 "$SCRIPT_DIR/data/dotcms/logs"
sudo chown -R 10001:10001 "$SCRIPT_DIR/data/dotcms/shared"
sudo chmod -R 777 "$SCRIPT_DIR/data/dotcms/shared"

echo "Fixing permissions for Postgres data directory..."
# sudo rm -rf "$SCRIPT_DIR/data/postgres"/*  # WARNING: This will erase all existing Postgres data
sudo chown -R 999:999 "$SCRIPT_DIR/data/postgres"
sudo chmod -R 700 "$SCRIPT_DIR/data/postgres"

# Check for Dockerfile before build
DOCKERFILE_CONTEXT_COPY="COPY context.xml /srv/dotserver/tomcat/conf/context.xml"
if ! grep -q "$DOCKERFILE_CONTEXT_COPY" "$SCRIPT_DIR/Dockerfile"; then
  echo "$DOCKERFILE_CONTEXT_COPY" >> "$SCRIPT_DIR/Dockerfile"
  echo "[INFO] Added context.xml copy step to Dockerfile."
fi
cat > "$SCRIPT_DIR/context.xml" <<EOF
<Context>
  <Resource name="jdbc/dotCMSPool"
            auth="Container"
            type="javax.sql.DataSource"
            maxTotal="100"
            maxIdle="30"
            maxWaitMillis="10000"
            username="dotcms"
            password="dotcms"
            driverClassName="org.postgresql.Driver"
            url="jdbc:postgresql://dotcms-postgres:5432/dotcms"/>
</Context>
EOF
if [ ! -f "$SCRIPT_DIR/Dockerfile" ]; then
  echo "[ERROR] Dockerfile not found in $SCRIPT_DIR. Aborting dotCMS build."
  exit 1
fi

# Remove and recreate network
if docker network inspect dotcms-net >/dev/null 2>&1; then
  docker network rm dotcms-net
fi
docker network create dotcms-net

Load postgres image from image-cache if available
CACHE_DIR="$SCRIPT_DIR/../image-cache"
if [ -f "$CACHE_DIR/postgres.tar" ]; then
  echo "[backend] Loading postgres from image-cache..."
  docker load -i "$CACHE_DIR/postgres.tar"
fi

POSTGRES_USER="dotcmsdbuser"
POSTGRES_PASSWORD="password"
POSTGRES_DB="dotcms"
if ! docker ps -a --format '{{.Names}}' | grep -q '^dotcms-postgres$'; then
  docker run --name dotcms-postgres --network dotcms-net \
    -e POSTGRES_USER="$POSTGRES_USER" \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    -e POSTGRES_DB="$POSTGRES_DB" \
    -v "$SCRIPT_DIR/data/postgres:/var/lib/postgresql/data" \
    -d pgvector/pgvector:pg16 \
    postgres -c 'max_connections=400' -c 'shared_buffers=128MB'
fi

# Wait for Postgres to be ready
echo "Waiting for Postgres to be ready..."
for i in {1..30}; do
  docker exec dotcms-postgres pg_isready -U dotcmsdbuser -d dotcms -h localhost -p 5432 >/dev/null 2>&1 && break
  sleep 5
done
if ! docker exec dotcms-postgres pg_isready -U dotcmsdbuser -d dotcms -h localhost -p 5432 >/dev/null 2>&1; then
  echo "[ERROR] Postgres did not become ready in time. Aborting dotCMS startup."
  exit 1
fi

# Load from image-cache if available
CACHE_DIR="$SCRIPT_DIR/../image-cache"
if [ -f "$CACHE_DIR/elastic.tar" ]; then
  echo "[backend] Loading elastic from image-cache..."
  docker load -i "$CACHE_DIR/elastic.tar"
fi

# Start Elasticsearch container
if ! docker ps -a --format '{{.Names}}' | grep -q '^dotcms-elasticsearch$'; then
  docker run --name dotcms-elasticsearch --network dotcms-net -d \
    -e "discovery.type=single-node" \
    -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
    -e "xpack.security.enabled=false" \
    -p 9200:9200 \
    docker.elastic.co/elasticsearch/elasticsearch:7.17.14
fi

# # Wait for Elasticsearch to be ready
# echo "Waiting for Elasticsearch to be ready..."
# for i in {1..120}; do
#   STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9200)
#   if [ "$STATUS" = "200" ]; then
#     break
#   fi
#   sleep 10
# done
# STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9200)
# if [ "$STATUS" != "200" ]; then
#   echo "[ERROR] Elasticsearch did not become ready in time. Aborting dotCMS startup."
#   exit 1
# fi
      
# Wait for Elasticsearch to be ready
echo "Waiting for Elasticsearch to be ready..."
for i in {1..120}; do
  # Query the cluster health API and check for a yellow or green status
  HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:9200/_cluster/health?wait_for_status=yellow&timeout=10s")
  if [ "$HEALTH_STATUS" = "200" ]; then
    echo "Elasticsearch is ready with yellow or green status."
    break
  fi
  echo "Waiting for Elasticsearch cluster to be ready... (attempt $i/120)"
  sleep 10
done

# Final check
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:9200/_cluster/health?wait_for_status=yellow&timeout=1s")
if [ "$HEALTH_STATUS" != "200" ]; then
  echo "[ERROR] Elasticsearch did not become ready in time. Check container logs: docker logs dotcms-elasticsearch"
  exit 1
fi

# Load from image-cache if available
CACHE_DIR="$SCRIPT_DIR/../image-cache"
if [ -f "$CACHE_DIR/dotcms.tar" ]; then
  echo "[backend] Loading dotcms from image-cache..."
  docker load -i "$CACHE_DIR/dotcms.tar"
fi

cd "$SCRIPT_DIR"
docker build -t dotcms .

# Return to original directory if needed
cd - >/dev/null || true

# --- ADMIN CREDENTIALS ---
  # Username: admin
  # Password: 7e2e1b2c-2e2e-4e2e-8e2e-2e2e2e2e2e2e
docker run --name dotcms-app --network dotcms-net -d \
  -p 8086:8082 -p 8443:8443 -p 4000:4000 \
  -v "$SCRIPT_DIR/data/dotcms/shared:/data/shared" \
  -e CMS_JAVA_OPTS='-Xmx1g ' \
  -e LANG='C.UTF-8' \
  -e TZ='UTC' \
  -e DB_BASE_URL="jdbc:postgresql://dotcms-postgres/dotcms" \
  -e DB_USERNAME="$POSTGRES_USER" \
  -e DB_PASSWORD="$POSTGRES_PASSWORD" \
  -e DOT_INITIAL_ADMIN_PASSWORD='7e2e1b2c-2e2e-4e2e-8e2e-2e2e2e2e2e2e' \
  -e DOT_DOTCMS_CLUSTER_ID='dotcms-production' \
  -e GLOWROOT_ENABLED='true' \
  -e GLOWROOT_WEB_UI_ENABLED='true' \
  -e CUSTOM_STARTER_URL='https://repo.dotcms.com/artifactory/libs-release-local/com/dotcms/starter/empty_20241105/starter-empty_20241105.zip' \
  -e DOT_ES_ENDPOINTS='http://dotcms-elasticsearch:9200' \
  --restart=always \
  dotcms

# Load from image-cache if available
echo "Loading Promtail image from image-cache if available..."
CACHE_DIR="$SCRIPT_DIR/../image-cache"
if [ -f "$CACHE_DIR/promtail.tar" ]; then
  echo "[backend] Loading promtail from image-cache..."
  docker load -i "$CACHE_DIR/promtail.tar"
fi

# Start Promtail as a sidecar container (optional)
echo "Starting Promtail for log collection..."
if [ -f "$SCRIPT_DIR/promtail-config.yaml" ]; then
  docker run --name promtail-dotcms --network dotcms-net -d \
    -v "$SCRIPT_DIR/data/dotcms/logs:/var/log/dotcms" \
    -v "$SCRIPT_DIR/promtail-config.yaml:/etc/promtail/promtail-config.yaml" \
    grafana/promtail:2.9.11 -config.file=/etc/promtail/promtail-config.yaml
fi
echo "Promtail started successfully."