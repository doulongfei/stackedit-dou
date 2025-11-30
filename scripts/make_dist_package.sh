#!/usr/bin/env bash
set -euo pipefail

# Build frontend and create a combined distributable tarball containing:
# - dist/ (Vite build output)
# - server/ (Flask backend)
# - package.json, README.md

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

echo "Building frontend..."
npm ci
npm run build

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
VERSION=$(node -p "require('./package.json').version")
OUT_NAME="stackedit-bundle-${VERSION}-${TIMESTAMP}.tar.gz"

echo "Packaging files into $OUT_NAME ..."
tar --exclude='.git' --exclude='node_modules' -czf "$OUT_NAME" dist server package.json README.md scripts/install.sh

echo "Created: $OUT_NAME"

echo "Tip: you can copy the generated tarball to the target server and extract it there. Then run the included scripts/install.sh as root to install and run the service."
