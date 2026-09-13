"""Forward Smart Loop JSON readings from an ESP32 serial port to Firebase."""

from __future__ import annotations

import argparse
import json
import time
import urllib.error
import urllib.parse
import urllib.request

import serial
from serial import SerialException


def upload_reading(database_url: str, reading: dict[str, object]) -> None:
    device_id = str(reading.get("deviceId", "")).strip()
    if not device_id:
        raise ValueError("Reading does not contain deviceId")

    payload = {
        "currentFlowRate": float(reading.get("currentFlowRate", 0)),
        "totalLiters": float(reading.get("totalLiters", 0)),
        "status": str(reading.get("status", "offline")),
        "lastSeen": {".sv": "timestamp"},
    }
    safe_device_id = urllib.parse.quote(device_id, safe="")
    url = f"{database_url.rstrip('/')}/devices/{safe_device_id}.json"
    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="PATCH",
    )
    with urllib.request.urlopen(request, timeout=10) as response:
        if response.status < 200 or response.status >= 300:
            raise RuntimeError(f"Firebase returned HTTP {response.status}")


def run(port: str, baud_rate: int, database_url: str, once: bool) -> None:
    print(f"Smart Loop bridge: {port} -> {database_url}", flush=True)

    while True:
        try:
            with serial.Serial(port, baud_rate, timeout=1) as connection:
                connection.dtr = False
                connection.rts = False
                print("ESP32 connected. Waiting for DATA lines...", flush=True)

                while True:
                    line = connection.readline().decode("utf-8", errors="replace").strip()
                    if not line.startswith("DATA:"):
                        continue

                    reading = json.loads(line.removeprefix("DATA:"))
                    upload_reading(database_url, reading)
                    print(
                        "Uploaded "
                        f"{reading['deviceId']}: "
                        f"{reading['currentFlowRate']} L/min, "
                        f"{reading['totalLiters']} L",
                        flush=True,
                    )
                    if once:
                        return
        except (SerialException, OSError, ValueError, json.JSONDecodeError, urllib.error.URLError) as error:
            print(f"Bridge error: {error}. Retrying in 2 seconds...", flush=True)
            time.sleep(2)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", default="COM5")
    parser.add_argument("--baud-rate", type=int, default=115200)
    parser.add_argument("--database-url", required=True)
    parser.add_argument("--once", action="store_true")
    return parser.parse_args()


if __name__ == "__main__":
    arguments = parse_args()
    run(
        port=arguments.port,
        baud_rate=arguments.baud_rate,
        database_url=arguments.database_url,
        once=arguments.once,
    )
