#!/usr/bin/env bash
set -euo pipefail

# Minimal "curl | bash" installer that downloads the latest PyInstaller bundle from GitHub Releases
# and installs it as a systemd service.
# Usage (run as root or with sudo):
# curl -fsSL https://raw.githubusercontent.com/doulongfei/stackedit-dou/master/scripts/install_latest.sh | sudo bash

REPO_OWNER="doulongfei"
REPO_NAME="stackedit-dou"
ASSET_GLOB="stackedit-server-"  # looks for asset names starting with this prefix
TARGET_DIR="/opt/stackedit"
SERVICE_NAME="stackedit"
SERVICE_USER="stackedit"
PORT=${PORT:-8080}

echo "==> Installing latest StackEdit server from GitHub Releases (${REPO_OWNER}/${REPO_NAME})"

if [ "$(id -u)" -ne 0 ]; then
  echo "This script should be run as root (or with sudo)." >&2
  exit 1
fi

TMPDIR=$(mktemp -d /tmp/stackedit-install.XXXX)
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

echo "Fetching latest release info..."
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
JSON=$(curl -sSfL "$API_URL") || { echo "Failed to fetch release info" >&2; exit 2; }

ASSET_URL=$(echo "$JSON" | grep "browser_download_url" | grep "$ASSET_GLOB" | head -n1 | cut -d '"' -f 4 || true)
if [ -z "$ASSET_URL" ]; then
  echo "No release asset matching '${ASSET_GLOB}' found in latest release. Please check the repository releases." >&2
  exit 3
fi

echo "Found asset: $ASSET_URL"

FNAME="$TMPDIR/$(basename "$ASSET_URL")"
echo "Downloading to $FNAME..."
curl -sSfL "$ASSET_URL" -o "$FNAME" || { echo "Download failed" >&2; exit 4; }

echo "Extracting..."
tar -C "$TMPDIR" -xzf "$FNAME"

# find the binary inside extracted files
BIN_PATH=$(find "$TMPDIR" -type f -perm -111 -maxdepth 2 -name 'stackedit-server*' -print -quit || true)
if [ -z "$BIN_PATH" ]; then
  # fallback: any file in archive
  BIN_PATH=$(find "$TMPDIR" -type f -maxdepth 2 -print -quit || true)
fi

if [ -z "$BIN_PATH" ]; then
  echo "No binary found in archive" >&2
  exit 5
fi

echo "Binary found: $BIN_PATH"

echo "Creating target directory: $TARGET_DIR"
mkdir -p "$TARGET_DIR"

if ! id -u "$SERVICE_USER" >/dev/null 2>&1; then
  echo "Creating system user: $SERVICE_USER"
  useradd --system --home "$TARGET_DIR" --shell /usr/sbin/nologin "$SERVICE_USER" || true
fi

cp "$BIN_PATH" "$TARGET_DIR/$(basename "$BIN_PATH")"
chmod +x "$TARGET_DIR/$(basename "$BIN_PATH")"
chown -R "$SERVICE_USER":"$SERVICE_USER" "$TARGET_DIR"

SYSTEMD_PATH="/etc/systemd/system/${SERVICE_NAME}.service"
echo "Generating systemd unit: $SYSTEMD_PATH"
cat > "$SYSTEMD_PATH" <<EOF
[Unit]
Description=StackEdit server (auto-installed)
After=network.target

[Service]
User=${SERVICE_USER}
WorkingDirectory=${TARGET_DIR}
ExecStart=${TARGET_DIR}/$(basename "$BIN_PATH")
Restart=on-failure
Environment=LISTENING_PORT=${PORT}
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now ${SERVICE_NAME}

echo "Installation complete. Check status: systemctl status ${SERVICE_NAME}"
echo "Notes: pandoc/wkhtmltopdf are NOT bundled — install them on your host if you need PDF/pandoc features."
