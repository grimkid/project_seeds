#!/bin/bash
# Script pentru a crea pachete de transfer SEPARATE pentru dotCMS (Assets + DB)

set -e

# --- Variabile de Configurare ---
DB_CONTAINER_NAME="dotcms-postgres"
DB_USER="dotcmsdbuser"
DB_NAME="dotcms"
BACKUP_FILE_NAME="backup.sqlc"
ASSETS_PACKAGE_NAME="dotcms_assets.tar.gz"
DATA_DIR="data"
DB_DATA_DIR="${DATA_DIR}/postgres"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_FILE_HOST_PATH="${SCRIPT_DIR}/${BACKUP_FILE_NAME}"

# --- Verificări Inițiale ---
echo "Verificare mediu..."
if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER_NAME}$"; then
  echo "EROARE: Containerul '${DB_CONTAINER_NAME}' nu rulează."
  exit 1
fi
if [ ! -d "${DATA_DIR}" ]; then
  echo "EROARE: Folderul '${DATA_DIR}' nu a fost găsit."
  exit 1
fi

# --- Pasul 1: Backup la Baza de Date ---
echo "---------------------------------------------"
echo "Pasul 1: Se creează backup-ul bazei de date..."
docker exec -t "${DB_CONTAINER_NAME}" pg_dump -U "${DB_USER}" -d "${DB_NAME}" -F c -b -v -f "/var/lib/postgresql/data/${BACKUP_FILE_NAME}"

# --- MODIFICARE AICI: Buclă de așteptare robustă ---
echo "Se așteaptă apariția fișierului de backup pe host..."
COUNTER=0
TIMEOUT=60 # Așteaptă maxim 10 secunde
while [ ! -f "${DB_DATA_DIR}/${BACKUP_FILE_NAME}" ]; do
  if [ $COUNTER -ge $TIMEOUT ]; then
    echo "EROARE: Timeout! Fișierul de backup nu a apărut pe host în ${TIMEOUT} secunde."
    echo "Verifică permisiunile folderului '${DB_DATA_DIR}'."
    exit 1
  fi
  sleep 1
  COUNTER=$((COUNTER + 1))
done
echo "Fișierul a fost găsit în ${COUNTER} secunde."

# --- Pasul 2: Mutarea Backup-ului DB lângă Script ---
echo "---------------------------------------------"
echo "Pasul 2: Se mută backup-ul bazei de date în folderul curent..."
mv "${DB_DATA_DIR}/${BACKUP_FILE_NAME}" "${BACKUP_FILE_HOST_PATH}"
echo "Backup-ul bazei de date a fost mutat la: ${BACKUP_FILE_HOST_PATH}"

# --- Pasul 3: Arhivarea Folderului de Assets ---
echo "---------------------------------------------"
echo "Pasul 3: Se creează arhiva de assets '${ASSETS_PACKAGE_NAME}'..."
rm -f "${ASSETS_PACKAGE_NAME}"
tar -czvf "${ASSETS_PACKAGE_NAME}" "${DATA_DIR}"

echo "---------------------------------------------"
echo "PROCES FINALIZAT!"
echo "Au fost create două fișiere de transfer:"
echo "1. ${ASSETS_PACKAGE_NAME}"
echo "2. ${BACKUP_FILE_NAME}"
echo "Trebuie să trimiți AMBELE fișiere."