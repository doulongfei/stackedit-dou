#!/usr/bin/env bash
set -euo pipefail

# One-click installer for StackEdit bundle (assumes this script lives at the top-level of the extracted bundle)
# What it does:
#  - Installs server into a target path (default /opt/stackedit)
#  - Creates a python virtualenv and installs `server/requirements.txt`
#  - Creates a dedicated system user `stackedit` (if missing)
#  - Generates a systemd unit file to run the server
#  - Starts / enables the service

TARGET_DIR=/opt/stackedit
SERVICE_USER=stackedit
SERVICE_NAME=stackedit
PYTHON_BIN=python3
PORT=8080
DEBUG_FLAG=false

function usage() {
  cat <<EOF
Usage: $0 [--target /opt/stackedit] [--port 8080] [--debug true|false] [--user stackedit]

This script expects to be running from the top-level of an extracted package that contains:
  - server/ (Flask backend)
  - dist/   (frontend build)

It will create a venv at TARGET_DIR/venv and a systemd unit named ${SERVICE_NAME}.service.
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET_DIR="$2"; shift 2;;
    --port) PORT="$2"; shift 2;;
    --debug) DEBUG_FLAG="$2"; shift 2;;
    --user) SERVICE_USER="$2"; shift 2;;
    -h|--help) usage;;
    *) echo "Unknown option: $1"; usage;;
  esac
done

if ! command -v $PYTHON_BIN >/dev/null 2>&1; then
  echo "Error: $PYTHON_BIN not found. Please install Python 3.10+ first." >&2
  exit 2
fi

if [[ ! -d server ]] || [[ ! -d dist ]]; then
  echo "This script must be run from the top-level of the extracted package which contains 'server/' and 'dist/' folders." >&2
  exit 3
fi

echo "Installing to: $TARGET_DIR"

if id -u "$SERVICE_USER" >/dev/null 2>&1; then
  echo "Service user $SERVICE_USER already exists"
else
  echo "Creating system user: $SERVICE_USER"
  sudo useradd --system --home "$TARGET_DIR" --shell /usr/sbin/nologin "$SERVICE_USER" || true
fi

echo "Creating target directory and copying files..."
sudo mkdir -p "$TARGET_DIR"
sudo chown -R $(id -u):$(id -g) "$TARGET_DIR" || true
rsync -a --delete dist server package.json README.md "$TARGET_DIR/"

echo "Setting up python virtualenv inside $TARGET_DIR/venv"
sudo chown -R $(id -u):$(id -g) "$TARGET_DIR"
python3 -m venv "$TARGET_DIR/venv"
source "$TARGET_DIR/venv/bin/activate"
pip install --upgrade pip

if [[ -f "$TARGET_DIR/server/requirements.txt" ]]; then
  echo "Installing python requirements..."
  pip install -r "$TARGET_DIR/server/requirements.txt"
else
  echo "Warning: no server/requirements.txt found — skipping pip install"
fi

deactivate || true

echo "Creating systemd service file for ${SERVICE_NAME} ..."
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}.service"
sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=StackEdit Flask server
After=network.target

[Service]
User=${SERVICE_USER}
WorkingDirectory=${TARGET_DIR}
ExecStart=${TARGET_DIR}/venv/bin/python -u server/app.py
Restart=on-failure
Environment=LISTENING_PORT=${PORT}
Environment=DEBUG_FLAG=${DEBUG_FLAG}
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd and enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable --now ${SERVICE_NAME}.service

echo "Service status (brief):"
sudo systemctl status ${SERVICE_NAME} --no-pager --lines=10 || true

echo "Installation complete. The server should be reachable on port ${PORT} (if permitted by firewall)."

echo "Notes & next steps:"
echo " - If your server uses external executables (pandoc, wkhtmltopdf), install them on the system before starting."
echo " - For production deployments, consider using gunicorn or containerization (Docker) rather than the Flask builtin server."
