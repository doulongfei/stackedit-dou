#!/usr/bin/env bash
set -euo pipefail

# Build a single-file PyInstaller binary for the Flask server (Linux target)
# Usage: ./scripts/pyinstaller_build.sh [--onefile] [--name stackedit-server] [--skip-front] [--arch <arch>]

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

NAME="stackedit-server"
ONEFILE=true
SKIP_FRONT=false
ARCH=linux-x86_64

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2;;
    --no-onefile) ONEFILE=false; shift;;
    --skip-front|--no-front) SKIP_FRONT=true; shift;;
    --arch) ARCH="$2"; shift 2;;
    -h|--help) echo "Usage: $0 [--name <binary-name>] [--no-onefile]"; exit 0;;
    *) echo "Unknown option $1"; exit 1;;
  esac
done

if [ "$SKIP_FRONT" = false ]; then
  echo "Building frontend (vite) ..."
  npm ci
  npm run build
else
  echo "Skipping frontend build (dist should exist)"
fi

BUILD_DIR=.pyinstaller_build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "Creating isolated venv for pyinstaller ..."
python3 -m venv "$BUILD_DIR/venv"
source "$BUILD_DIR/venv/bin/activate"
pip install --upgrade pip
pip install pyinstaller -q
pip install -r server/requirements.txt -q

# PyInstaller add-data syntax uses ':' on linux
ADDDATA=("dist:dist" "server:server")

ARGS=(--noconfirm --clean)
if [ "$ONEFILE" = true ]; then
  ARGS+=(--onefile)
fi

ARGS+=(--name "$NAME")

for d in "${ADDDATA[@]}"; do
  ARGS+=(--add-data "$d")
done

echo "Running PyInstaller, this may take a while..."
pyinstaller "${ARGS[@]}" server/app.py

OUT_DIR=dist_pyinstaller
rm -rf "$OUT_DIR" && mkdir -p "$OUT_DIR"

if [ "$ONEFILE" = true ]; then
  BIN_PATH="dist/$NAME"
  cp "$BIN_PATH" "$OUT_DIR/"
else
  cp -r dist/ "$OUT_DIR/" || true
  cp -r build/ "$OUT_DIR/" || true
fi

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
# try node first, fall back to python if node isn't available
if command -v node >/dev/null 2>&1; then
  VERSION=$(node -p "require('./package.json').version")
else
  VERSION=$(python3 -c "import json,sys; print(json.load(open('package.json'))['version'])")
fi
ARCHIVE="${NAME}-${VERSION}-${TIMESTAMP}-${ARCH}.tar.gz"
tar -C "$OUT_DIR" -czf "$ARCHIVE" .

echo "PyInstaller bundle created: $ARCHIVE"

echo "Note: pandoc/wkhtmltopdf and other system binaries are NOT bundled and must be installed on target host."
