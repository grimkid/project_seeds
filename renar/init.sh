#!/bin/bash
# Script to make all .sh files in all subdirectories executable
ROOT_DIR="$(dirname "$0")"
echo "[init] Making all .sh files in $ROOT_DIR and subdirectories executable..."
find "$ROOT_DIR" -type f -name '*.sh' -exec chmod +x {} \;
echo "[init] Done."
