# BUENATURA-OMARCHY-TRADER

Omarchy TradingView and Pine Script signal plugin for top-bar alerts and trading workflow notifications.

## Features

- Displays current signal (BUY, SELL, HOLD) in the Omarchy top bar
- Click to open TradingView
- Easy to extend with actual signal logic

## Installation

1. Clone this repository to your Omarchy plugins directory:

   ```bash
   git clone https://github.com/ValoLoco/BUENATURA-OMARCHY-TRADER.git ~/.config/omarchy/plugins/io.github.ValoLoco.tradingview-signals
   ```

2. Enable the plugin:

   ```bash
   omarchy plugin enable io.github.ValoLoco.tradingview-signals
   ```

3. The plugin will automatically appear in the bar (positioned after the power widget).

## Configuration

Edit `Panel.qml` to adjust the signal source or appearance.

## Development

This plugin follows Omarchy plugin best practices:
- Uses QML for the UI
- Proper manifest.json with schemaVersion 1
- Declares bar-widget kind
- Integrated into the bar layout via omarchy bar commands

## License

MIT