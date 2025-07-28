#!/bin/bash
# Run provision-users.sh inside a one-time Alpine container with curl and jq, on the internal-net Docker network
# Usage: ./configure-dotcms.sh [any extra args for provision-users.sh]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/provision-users.sh"

if [ ! -f "$SCRIPT_PATH" ]; then
  echo "[configure-dotcms] provision-users.sh not found in $SCRIPT_DIR"
  exit 1
fi

echo "[configure-dotcms] Running provision-users.sh in a one-time Alpine container on internal-net..."
docker run --rm --network internal-net \
  -v "$SCRIPT_PATH:/provision-users.sh:ro" \
  alpine:latest \
  sh -c "apk add --no-cache bash curl jq && bash /provision-users.sh $@"
