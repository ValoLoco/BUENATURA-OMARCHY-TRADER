#!/usr/bin/env python3
"""
Systemd service installer for the TradingView webhook receiver
Run with: python3 install_service.py [--user]
"""

import os
import sys
import subprocess
import argparse

SERVICE_NAME = "tradingview-webhook-receiver"
SERVICE_FILE = f"{SERVICE_NAME}.service"

SERVICE_CONTENT = f"""[Unit]
Description=TradingView Webhook Receiver for Omarchy Plugin
After=network.target

[Service]
Type=simple
ExecStart={os.path.expanduser('~')}/.config/omarchy/plugins/io.github.ValoLoco.tradingview-signals/services/webhook_receiver.py
Restart=on-failure
RestartSec=5
Environment=TRADINGVIEW_WEBHOOK_PORT=8080
Environment=TRADINGVIEW_DATA_FILE=/tmp/tradingview-signals.json
Environment=TRADINGVIEW_SYMBOLS=BTCUSDT,ETHUSDT,AAPL

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier={SERVICE_NAME}

[Install]
WantedBy=default.target
"""

def install_service(user_mode=True):
    if user_mode:
        service_dir = os.path.expanduser("~/.config/systemd/user")
        cmd_prefix = ["systemctl", "--user"]
    else:
        service_dir = "/etc/systemd/system"
        cmd_prefix = ["systemctl"]
    
    os.makedirs(service_dir, exist_ok=True)
    service_path = os.path.join(service_dir, SERVICE_FILE)
    
    with open(service_path, 'w') as f:
        f.write(SERVICE_CONTENT)
    
    print(f"Service file written to: {service_path}")
    
    # Reload systemd
    subprocess.run(cmd_prefix + ["daemon-reload"], check=True)
    
    # Enable and start
    subprocess.run(cmd_prefix + ["enable", SERVICE_NAME], check=True)
    subprocess.run(cmd_prefix + ["start", SERVICE_NAME], check=True)
    
    print(f"Service {SERVICE_NAME} installed and started!")
    print(f"Check status: {' '.join(cmd_prefix)} status {SERVICE_NAME}")
    print(f"View logs: journalctl {'--user' if user_mode else ''} -u {SERVICE_NAME} -f")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--system", action="store_true", help="Install as system service (requires sudo)")
    args = parser.parse_args()
    
    try:
        install_service(user_mode=not args.system)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        sys.exit(1)