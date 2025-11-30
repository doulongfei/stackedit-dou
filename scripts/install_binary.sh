#!/usr/bin/env bash
set -euo pipefail

# Install a PyInstaller-built single-file binary for StackEdit server
# Usage: sudo ./scripts/install_binary.sh /path/to/stackedit-server [--target /opt/stackedit] [--port 8080]

BINARY_PATH=${1:-}
TARGET_DIR=/opt/stackedit
SERVICE_USER=stackedit
SERVICE_NAME=stackedit
PORT=8080

if [ -z "$BINARY_PATH" ]; then
  echo "Usage: $0 /path/to/binary [--target /opt/stackedit] [--port 8080]" >&2
  exit 1
fi

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET_DIR="$2"; shift 2;;
    --port) PORT="$2"; shift 2;;
    *) echo "Unknown option $1"; exit 1;;
  esac
done

if [[ ! -f "$BINARY_PATH" ]]; then
  echo "Binary not found: $BINARY_PATH" >&2
  exit 2
fi

echo "Installing binary to ${TARGET_DIR} ..."
sudo mkdir -p "$TARGET_DIR"
sudo cp "$BINARY_PATH" "$TARGET_DIR/$(basename "$BINARY_PATH")"
sudo chmod +x "$TARGET_DIR/$(basename "$BINARY_PATH")"

if id -u "$SERVICE_USER" >/dev/null 2>&1; then
  echo "Service user $SERVICE_USER already exists"
else
  sudo useradd --system --home "$TARGET_DIR" --shell /usr/sbin/nologin "$SERVICE_USER" || true
fi

SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}.service"
sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=StackEdit server (PyInstaller binary)
After=network.target

[Service]
User=${SERVICE_USER}
WorkingDirectory=${TARGET_DIR}
ExecStart=${TARGET_DIR}/$(basename "$BINARY_PATH")
Restart=on-failure
Environment=LISTENING_PORT=${PORT}
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now ${SERVICE_NAME}.service

echo "Installation done. Check service status: sudo systemctl status ${SERVICE_NAME} -l"
