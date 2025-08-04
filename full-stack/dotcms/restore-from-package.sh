#!/bin-bash
# Script pentru a restaura un mediu dotCMS din pachete separate (Assets + DB)

set -e

# --- Variabile de Configurare ---
DB_CONTAINER_NAME="dotcms-postgres"
DB_USER="dotcmsdbuser"
DB_NAME="dotcms"
BACKUP_FILE_NAME="backup.sqlc"
ASSETS_PACKAGE_NAME="dotcms_assets.tar.gz"
DATA_DIR="data"
DB_DATA_DIR="${DATA_DIR}/postgres"
POSTGRES_IMAGE="pgvector/pgvector:pg16"
POSTGRES_USER_ENV="dotcmsdbuser"
POSTGRES_PASSWORD_ENV="password"
POSTGRES_DB_ENV="dotcms"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_FILE_HOST_PATH="${SCRIPT_DIR}/${BACKUP_FILE_NAME}"

# --- Verificări Inițiale ---
echo "Verificare fișiere necesare..."
if [ ! -f "${ASSETS_PACKAGE_NAME}" ] || [ ! -f "${BACKUP_FILE_NAME}" ]; then
  echo "EROARE: Unul sau ambele fișiere de transfer lipsesc."
  echo "Asigură-te că '${ASSETS_PACKAGE_NAME}' ȘI '${BACKUP_FILE_NAME}' se află lângă acest script."
  exit 1
fi

# --- Pasul 1: Curățarea Mediului Existent ---
echo "---------------------------------------------"
echo "Pasul 1: Se curăță mediul Docker existent..."
docker rm -f dotcms-app "${DB_CONTAINER_NAME}" promtail-dotcms dotcms-elasticsearch 2>/dev/null || true
if [ -d "${DATA_DIR}" ]; then
  echo "Se șterge folderul de date vechi..."
  sudo rm -rf "${DATA_DIR}"
fi

# --- Pasul 2: Dezarhivarea Asset-urilor ---
echo "---------------------------------------------"
echo "Pasul 2: Se dezarhivează pachetul de assets..."
tar -xzvf "${ASSETS_PACKAGE_NAME}"
echo "Folderul '${DATA_DIR}' (cu assets) a fost restaurat din arhivă."

# --- Pasul 3: Pornirea Containerului PostgreSQL ---
echo "---------------------------------------------"
echo "Pasul 3: Se pornește un container PostgreSQL nou..."
docker run --name "${DB_CONTAINER_NAME}" --network internal-net \
  -e POSTGRES_USER="${POSTGRES_USER_ENV}" \
  -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD_ENV}" \
  -e POSTGRES_DB="${POSTGRES_DB_ENV}" \
  -v "$(pwd)/${DATA_DIR}/postgres:/var/lib/postgresql/data" \
  -d "${POSTGRES_IMAGE}" \
  postgres -c 'max_connections=400' -c 'shared_buffers=128MB'

echo "Se așteaptă ca serverul PostgreSQL să pornească (15 secunde)..."
sleep 15

# --- Pasul 4: Restaurarea Bazei de Date ---
echo "---------------------------------------------"
echo "Pasul 4: Se restaurează baza de date folosind '${BACKUP_FILE_NAME}'..."
# Trimitem fișierul de backup de lângă script către comanda pg_restore
docker exec -i "${DB_CONTAINER_NAME}" pg_restore -U "${DB_USER}" -d "${DB_NAME}" -v -c < "${BACKUP_FILE_HOST_PATH}"
echo "Restaurarea bazei de date a fost finalizată."

# --- Finalizare ---
echo "---------------------------------------------"
echo "PROCES FINALIZAT!"
echo "Mediul a fost restaurat cu succes."
echo "Acum poți porni restul serviciilor dotCMS folosind scriptul tău './boot-dotcms.sh'."