#!/usr/bin/env python3
import serial, subprocess, sys, time

# === Настройки ===
SERIAL_PORT  = '/dev/ttyACM0'
BAUD_RATE    = 115200
SCREEN_ID    = '2'             # ← тут «2», как в выводе kscreen-doctor
POLL_DELAY   = 0.1             # секунды между опросами

def rotate_screen(mode: str):
    """Применяет поворот через kscreen-doctor."""
    subprocess.run(
        ['kscreen-doctor', f'output.{SCREEN_ID}.rotation.{mode}'],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )

def main():
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    except Exception as e:
        print(f"Error opening {SERIAL_PORT}: {e}", file=sys.stderr)
        sys.exit(1)

    last = None
    print("Listener started. Awaiting tilt codes: L/R/N/I…")

    while True:
        byte = ser.read(1)
        if not byte:
            time.sleep(POLL_DELAY)
            continue

        code = byte.decode('ascii', errors='ignore').upper()
        if code == last or code not in ('L','R','N','I'):
            continue
	# left & right почему то перепутаны
        if code == 'L':
            rotate_screen('right');     print("Rotated left ↺")
        elif code == 'R':
            rotate_screen('left');    print("Rotated right ↻")
        elif code == 'N':
            rotate_screen('normal');   print("Orientation: normal ⭢")
        elif code == 'I':
            rotate_screen('inverted'); print("Orientation: inverted ⭡")

        last = code
        time.sleep(POLL_DELAY)

if __name__ == '__main__':
    main()
