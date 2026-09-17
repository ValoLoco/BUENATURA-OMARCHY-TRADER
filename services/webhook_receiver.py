#!/usr/bin/env python3
"""
TradingView Webhook Receiver for Omarchy Plugin
Receives Pine Script webhook alerts and writes signal data for the QML service to pick up.
Run this as a background service: python3 webhook_receiver.py
"""

import json
import os
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import threading
import time

# Configuration
WEBHOOK_PORT = int(os.environ.get("TRADINGVIEW_WEBHOOK_PORT", "8080"))
DATA_FILE = os.environ.get("TRADINGVIEW_DATA_FILE", "/tmp/tradingview-signals.json")
ALLOWED_SYMBOLS = os.environ.get("TRADINGVIEW_SYMBOLS", "BTCUSDT,ETHUSDT,AAPL").split(",")

class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Parse the webhook payload
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length).decode('utf-8')
        
        try:
            # TradingView sends JSON payload
            payload = json.loads(post_data)
            
            # Extract signal info (TradingView webhook format varies)
            # Common formats:
            # {"symbol": "BTCUSDT", "signal": "BUY", "price": 50000, "timeframe": "15m"}
            # {"ticker": "BTCUSDT", "action": "buy", ...}
            
            symbol = payload.get('symbol') or payload.get('ticker') or payload.get('pair')
            signal = payload.get('signal') or payload.get('action') or payload.get('side')
            
            if signal:
                signal = signal.upper()
                if signal in ['BUY', 'LONG', 'ENTER LONG']:
                    signal = 'BUY'
                elif signal in ['SELL', 'SHORT', 'ENTER SHORT']:
                    signal = 'SELL'
                else:
                    signal = 'HOLD'
            
            if symbol and signal:
                # Validate symbol
                if symbol in ALLOWED_SYMBOLS or not ALLOWED_SYMBOLS:
                    # Write to data file for QML service
                    data = {
                        'symbol': symbol,
                        'signal': signal,
                        'timestamp': time.time(),
                        'price': payload.get('price') or payload.get('close'),
                        'timeframe': payload.get('timeframe', '15m')
                    }
                    
                    with open(DATA_FILE, 'w') as f:
                        json.dump(data, f)
                    
                    self.send_response(200)
                    self.send_header('Content-Type', 'application/json')
                    self.end_headers()
                    self.wfile.write(json.dumps({'status': 'ok', 'signal': signal}).encode())
                    print(f"Received webhook: {symbol} -> {signal}")
                    return
            
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b'Invalid payload')
            
        except json.JSONDecodeError:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b'Invalid JSON')
        except Exception as e:
            print(f"Error processing webhook: {e}")
            self.send_response(500)
            self.end_headers()
            self.wfile.write(b'Internal error')
    
    def do_GET(self):
        # Health check endpoint
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({'status': 'running', 'port': WEBHOOK_PORT}).encode())
    
    def log_message(self, format, *args):
        # Suppress default log messages
        pass

def run_server():
    server = HTTPServer(('localhost', WEBHOOK_PORT), WebhookHandler)
    print(f"TradingView webhook receiver running on http://localhost:{WEBHOOK_PORT}")
    print(f"Writing signals to: {DATA_FILE}")
    print(f"Allowed symbols: {ALLOWED_SYMBOLS}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down...")
        server.shutdown()

if __name__ == '__main__':
    run_server()