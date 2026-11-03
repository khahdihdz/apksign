#!/data/data/com.termux/files/usr/bin/sh
set -eu
REPO="https://github.com/khahdihdz/apksign.git"
APP_DIR="$HOME/apksign"
BIN_DIR="${PREFIX:-/data/data/com.termux/files/usr}/bin"

echo "[apksign] Cài đặt/cập nhật..."
if ! command -v git >/dev/null 2>&1; then
  pkg update -y
  pkg install -y git
fi

if [ -d "$APP_DIR/.git" ]; then
  git -C "$APP_DIR" fetch origin
  if ! git -C "$APP_DIR" diff --quiet || ! git -C "$APP_DIR" diff --cached --quiet; then
    git -C "$APP_DIR" stash push -u -m "apksign-installer-backup-$(date +%Y%m%d-%H%M%S)"
  fi
  git -C "$APP_DIR" pull --ff-only
elif [ -e "$APP_DIR" ]; then
  mv "$APP_DIR" "$APP_DIR.backup-$(date +%Y%m%d-%H%M%S)"
  git clone "$REPO" "$APP_DIR"
else
  git clone "$REPO" "$APP_DIR"
fi

chmod 700 "$APP_DIR/apksign" "$APP_DIR/drive-backup"
mkdir -p "$BIN_DIR"
ln -sf "$APP_DIR/apksign" "$BIN_DIR/apksign"
echo
echo "[apksign] Hoàn tất. Mở menu bằng lệnh: apksign"
echo "Keystore được giữ riêng tại: $HOME/.apksign"
