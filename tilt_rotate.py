#!/usr/bin/env python3
import os
import logging
import serial
import subprocess
import sys
import time

# === Configuration ===
SERIAL_PORT = os.getenv('TILT_SERIAL_PORT', '/dev/ttyACM0')
BAUD_RATE   = int(os.getenv('TILT_BAUD_RATE', '115200'))
SCREEN_ID   = os.getenv('TILT_SCREEN_ID', '2')
POLL_DELAY  = float(os.getenv('TILT_POLL_DELAY', '0.1'))

LOGFILE = os.path.expanduser('~/tilt_rotate.log')

# === Logging setup ===
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s %(levelname)-8s %(message)s',
    handlers=[
        logging.FileHandler(LOGFILE),
        logging.StreamHandler(sys.stdout)
    ]
)

def rotate_screen(mode: str):
    cmd = ['kscreen-doctor', f'output.{SCREEN_ID}.rotation.{mode}']
    logging.debug(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        logging.error(f"Rotation {mode} failed: {result.stderr.strip()}")
    else:
        logging.info(f"Rotated screen → {mode}")

def main():
    logging.info("=== tilt_rotate.py starting ===")
    logging.info(f"Config: SERIAL_PORT={SERIAL_PORT}, BAUD_RATE={BAUD_RATE}, SCREEN_ID={SCREEN_ID}")

    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    except Exception as e:
        logging.critical(f"Cannot open serial port {SERIAL_PORT}: {e!r}")
        sys.exit(1)

    time.sleep(2)
    ser.reset_input_buffer()

    last = None
    logging.info("Listener started. Awaiting tilt codes: L/R/N/I…")

    while True:
        try:
            byte = ser.read(1)
        except Exception as e:
            logging.error(f"Serial read error: {e!r}")
            time.sleep(POLL_DELAY)
            continue

        if not byte:
            time.sleep(POLL_DELAY)
            continue

        code = byte.decode('ascii', errors='ignore').upper()
        logging.debug(f"Received byte: {code!r}")

        if code == last or code not in ('L', 'R', 'N', 'I'):
            continue

        if code == 'L':
            rotate_screen('right')
            logging.debug("Code L → rotated right")
        elif code == 'R':
            rotate_screen('left')
            logging.debug("Code R → rotated left")
        elif code == 'N':
            rotate_screen('normal')
            logging.debug("Code N → normal orientation")
        elif code == 'I':
            rotate_screen('inverted')
            logging.debug("Code I → inverted")

        last = code
        time.sleep(POLL_DELAY)

if __name__ == '__main__':
    main()
