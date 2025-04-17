#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# install_tilt_rotate.sh
#
# Copies your existing tilt_rotate.py and tilt-rotate.service into the
# user systemd folder, installs dependencies, and (re)starts the service.
#
# Usage:
#   Place this script in the same dir as tilt_rotate.py and tilt-rotate.service
#   chmod +x install_tilt_rotate.sh
#   ./install_tilt_rotate.sh
# -----------------------------------------------------------------------------

echo "1) Installing dependencies…"
sudo apt update
sudo apt install -y python3-serial kscreen

echo "2) Preparing systemd user directory…"
USER_SVC_DIR="$HOME/.config/systemd/user"
mkdir -p "$USER_SVC_DIR"

echo "3) Copying files…"
cp tilt_rotate.py "$USER_SVC_DIR/tilt_rotate.py"
cp tilt-rotate.service "$USER_SVC_DIR/tilt-rotate.service"
chmod +x "$USER_SVC_DIR/tilt_rotate.py"

echo "4) Reloading systemd, enabling & restarting service…"
systemctl --user daemon-reload
systemctl --user enable tilt-rotate.service
systemctl --user restart tilt-rotate.service

echo
echo "✅ tilt-rotate service is now running."
echo "   ▶ Check status:   systemctl --user status tilt-rotate.service"
echo "   ▶ View logs:      journalctl --user -u tilt-rotate.service -f"
