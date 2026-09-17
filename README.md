# TradingView Signals - Omarchy Plugin

A production-ready Omarchy bar widget for displaying TradingView/Pine Script trading signals.

## Features

- **Real-time signal display**: Shows BUY/SELL/HOLD signals in the top bar
- **Color-coded alerts**: Green (BUY), Red (SELL), Yellow (HOLD)
- **Click to open chart**: Opens TradingView chart for the configured symbol
- **Context menu**: Quick actions (open chart, copy symbol, force update, configure)
- **Configurable via Omarchy settings**: Symbol, timeframe, colors, update interval
- **Webhook receiver**: Python service to receive Pine Script alerts
- **Systemd integration**: Auto-start webhook receiver on boot

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  TradingView    │────▶│  Webhook Receiver│────▶│  Signal Service │
│  (Pine Script)  │     │  (Python HTTP)   │     │  (QML Service)  │
└─────────────────┘     └──────────────────┘     └────────┬────────┘
                                                          │
                                                          ▼
                                                 ┌─────────────────┐
                                                 │  Bar Widget     │
                                                 │  (Panel.qml)    │
                                                 └─────────────────┘
```

## Installation

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/ValoLoco/BUENATURA-OMARCHY-TRADER/main/install.sh | bash
```

### Manual Install

```bash
# 1. Clone the plugin
git clone https://github.com/ValoLoco/BUENATURA-OMARCHY-TRADER.git \
  ~/.config/omarchy/plugins/io.github.ValoLoco.tradingview-signals

# 2. Enable the plugin
omarchy plugin enable io.github.ValoLoco.tradingview-signals

# 3. Add to bar
omarchy bar put io.github.ValoLoco.tradingview-signals --after omarchy.power

# 4. Restart shell
omarchy restart shell
```

## Configuration

Configure via `omarchy bar set` commands or edit `~/.config/omarchy/shell.json`:

```bash
# Set trading symbol
omarchy bar set io.github.ValoLoco.tradingview-signals symbol BTCUSDT

# Set timeframe
omarchy bar set io.github.ValoLoco.tradingview-signals timeframe 15m

# Set colors
omarchy bar set io.github.ValoLoco.tradingview-signals buyColor "#00ff00"
omarchy bar set io.github.ValoLoco.tradingview-signals sellColor "#ff0000"
omarchy bar set io.github.ValoLoco.tradingview-signals holdColor "#ffff00"

# Set update interval (milliseconds)
omarchy bar set io.github.ValoLoco.tradingview-signals updateInterval 60000
```

## TradingView Pine Script Setup

1. Copy `examples/pine-script-example.pine` to TradingView Pine Editor
2. Save and add to chart
3. Create alerts for "Buy Alert" and "Sell Alert"
4. In alert notification, select "Webhook URL"
5. Set webhook URL to: `http://your-host:8080/webhook`

## Webhook Receiver Service

### Run manually

```bash
cd ~/.config/omarchy/plugins/io.github.ValoLoco.tradingview-signals/services
python3 webhook_receiver.py
```

### Install as systemd service

```bash
cd ~/.config/omarchy/plugins/io.github.ValoLoco.tradingview-signals/services
python3 install_service.py --user
```

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TRADINGVIEW_WEBHOOK_PORT` | 8080 | Port for webhook receiver |
| `TRADINGVIEW_DATA_FILE` | /tmp/tradingview-signals.json | Signal data file |
| `TRADINGVIEW_SYMBOLS` | BTCUSDT,ETHUSDT,AAPL | Comma-separated allowed symbols |

## Development

### Plugin Structure

```
├── manifest.json          # Plugin manifest
├── Panel.qml             # Bar widget (main entry)
├── services/
│   ├── SignalService.qml # QML service for signal processing
│   ├── webhook_receiver.py # Python webhook HTTP server
│   └── install_service.py # Systemd service installer
├── examples/
│   └── pine-script-example.pine # Pine Script template
├── install.sh            # Quick install script
└── README.md             # This file
```

### Testing the Widget

```bash
# Validate plugin
omarchy plugin validate ~/.config/omarchy/plugins/io.github.ValoLoco.tradingview-signals

# Rescan plugins after changes
omarchy-shell shell rescanPlugins
```

### Sending Test Signals

```bash
# Test webhook locally
curl -X POST http://localhost:8080/webhook \
  -H "Content-Type: application/json" \
  -d '{"symbol": "BTCUSDT", "signal": "BUY", "price": 50000, "timeframe": "15m"}'

# Check data file
cat /tmp/tradingview-signals.json
```

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `omarchy plugin validate`
5. Submit a PR

## Support

- Issues: https://github.com/ValoLoco/BUENATURA-OMARCHY-TRADER/issues
- Omarchy Plugins: https://plugins.omarchy.org/