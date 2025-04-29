#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# install_tilt_rotate.sh
#
# Installs dependencies, copies tilt_rotate.py + tilt-rotate.service into the
# right ~/.config/systemd/user for either:
#   • the real user who ran `sudo ./…` (SUDO_USER),
#   • a direct root login, or
#   • a normal non-root user.
#
# Usage:
#   chmod +x install_tilt_rotate.sh
#   ./install_tilt_rotate.sh    # or sudo ./install_tilt_rotate.sh
# -----------------------------------------------------------------------------

# Determine target user & home
if [[ $EUID -eq 0 && -n ${SUDO_USER-} ]]; then
  # Ran via sudo: install into the invoking user’s home
  echo "⚠️  Do not run this installer as root or via sudo!"
  echo "    Please run it as your regular user (it will call sudo internally for apt)."
  exit 1
elif [[ $EUID -eq 0 ]]; then
  # Running as root (no sudo): install into root’s home
  TARGET_USER="root"
  TARGET_HOME="$HOME"
  echo "→ Running as real root: installing into $TARGET_HOME"
else
  # Running as normal user
  TARGET_USER="$USER"
  TARGET_HOME="$HOME"
  echo "→ Installing for normal user '$TARGET_USER' in $TARGET_HOME"
fi

# Dependencies
echo "1) Installing system packages…"
sudo apt update
sudo apt install -y python3-serial kscreen

# Prepare user‐level systemd directory
USER_SVC_DIR="$TARGET_HOME/.config/systemd/user"
echo "2) Preparing systemd user dir → $USER_SVC_DIR"
mkdir -p "$USER_SVC_DIR"
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config" || true
chown "$TARGET_USER:$TARGET_USER" "$USER_SVC_DIR"       || true

# Copy files
echo "3) Copying project files…"
cp tilt_rotate.py "$USER_SVC_DIR/"
cp tilt-rotate.service "$USER_SVC_DIR/"
chmod +x "$USER_SVC_DIR/tilt_rotate.py"
chown "$TARGET_USER:$TARGET_USER" \
  "$USER_SVC_DIR/tilt_rotate.py" \
  "$USER_SVC_DIR/tilt-rotate.service"

# Reload & start
echo "4) Reloading systemd, enabling & restarting service for $TARGET_USER…"
# Note: run these as the target user
if [[ $EUID -eq 0 ]]; then
  # use sudo -u to run under that user
  sudo -u "$TARGET_USER" systemctl --user daemon-reload
  sudo -u "$TARGET_USER" systemctl --user enable tilt-rotate.service
  sudo -u "$TARGET_USER" systemctl --user restart tilt-rotate.service
else
  systemctl --user daemon-reload
  systemctl --user enable tilt-rotate.service
  systemctl --user restart tilt-rotate.service
fi

echo
echo "✅ tilt-rotate has been installed for '$TARGET_USER'."
echo "   • Check status: sudo -u $TARGET_USER systemctl --user status tilt-rotate.service"
echo "   • View logs:    sudo -u $TARGET_USER journalctl --user -u tilt-rotate.service -f"
