#!/bin/bash
# Script to erase all cached images in the image-cache folder
CACHE_DIR="$(dirname "$0")"
echo "[image-cache] Erasing all cached images in $CACHE_DIR..."
find "$CACHE_DIR" -type f -name '*.tar' -exec rm -v {} \;
echo "[image-cache] Done."
