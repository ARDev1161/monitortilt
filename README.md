# Auto-Rotate Screen Based on Tilt Sensor

This project enables automatic rotation of your Linux desktop screen (KDE on Wayland or X11) using a tilt sensor connected to an RP2040 microcontroller. The RP2040 sends tilt codes `L`, `R`, `N`, and `I` over USB-Serial, and a Python listener on the PC processes these codes to rotate the display via `kscreen-doctor` (for Wayland) or `xrandr` (for X11).

---

## Project Structure

- `tilt_rotate.py` — the main Python listener script.
- `tilt-rotate.service` — systemd user unit file to manage the service.
- `install_tilt_rotate.sh` — installer script to set up dependencies and deploy files.

---

## Requirements

- **Operating System**: Linux with KDE desktop (X11 or Wayland).
- **Python**: Version 3.6 or newer.
- **Packages**:
  - `python3-serial` (or `pyserial` via pip) for serial communication.
  - `kscreen` for Wayland display rotation (install via `sudo apt install kscreen`).
  - `x11-xserver-utils` for X11 (`xrandr`) support.
- **Hardware**: RP2040-based board with an Arduino-compatible sketch that sends tilt codes.

---

## Installation

1. Clone or copy this repository into a folder, e.g. `~/tilt-rotate/`.
2. Make the installer script executable:
   ```bash
   chmod +x install_tilt_rotate.sh
   ```
3. Run the installer (you will be prompted for your sudo password):
   ```bash
   ./install_tilt_rotate.sh
   ```
   This script will:
   - Install required packages (`python3-serial` and `kscreen`).
   - Create the directory `~/.config/systemd/user` if it does not exist.
   - Copy `tilt_rotate.py` and `tilt-rotate.service` into that directory.
   - Reload the systemd user daemon, enable the service to start on login, and start it immediately.

---

## Configuration

- **Serial Port** in `tilt_rotate.py`:
  ```python
  SERIAL_PORT = '/dev/ttyACM0'  # or '/dev/ttyUSB0'
  ```
  Verify the correct device by listing USB serial devices:
  ```bash
  ls /dev/ttyACM* /dev/ttyUSB*
  ```

- **Display Identifier**:
  - **Wayland**: run
    ```bash
    kscreen-doctor --outputs
    ```
    Identify the output ID (e.g. `1` or `2`) and set:
    ```python
    SCREEN_ID = '2'
    ```
  - **X11**: run
    ```bash
    xrandr --query | grep " connected " | awk '{ print $1 }'
    ```
    Use the output name (e.g. `eDP-1`) with `xrandr` in the script.

---

## Usage

- The service starts automatically when you log into your KDE session.
- Check the service status with:
  ```bash
  systemctl --user status tilt-rotate.service
  ```
- Follow live logs with:
  ```bash
  journalctl --user -u tilt-rotate.service -f
  ```
- To run the listener manually (for debugging):
  ```bash
  ~/.config/systemd/user/tilt_rotate.py
  ```

---

## Troubleshooting

1. **Verify RP2040 output**:
   ```bash
   cat /dev/ttyACM0
   ```
   You should see `L`, `R`, `N`, or `I` when tilting the sensor.

2. **Check user groups**:
   ```bash
   groups
   ```
   Ensure your user is in the `dialout` group to access serial ports.

3. **View service logs**:
   ```bash
   journalctl --user -u tilt-rotate.service --no-pager
   ```

---

## License

This project is licensed under the MIT License © 2025

