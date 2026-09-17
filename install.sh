#!/usr/bin/env bash
# Install script for TradingView Signals Omarchy Plugin
# Run this to install the plugin on a fresh Omarchy system

set -e

PLUGIN_ID="io.github.ValoLoco.tradingview-signals"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"
REPO_URL="https://github.com/ValoLoco/BUENATURA-OMARCHY-TRADER.git"

echo "Installing TradingView Signals plugin for Omarchy..."

# Clone or update the plugin
if [ -d "$PLUGIN_DIR" ]; then
    echo "Plugin already exists, updating..."
    cd "$PLUGIN_DIR"
    git pull
else
    echo "Cloning plugin..."
    git clone "$REPO_URL" "$PLUGIN_DIR"
fi

# Enable the plugin
echo "Enabling plugin..."
omarchy plugin enable "$PLUGIN_ID"

# Add to bar (after power widget)
echo "Adding to bar..."
omarchy bar put "$PLUGIN_ID" --after omarchy.power

echo "Installation complete!"
echo "Restart the shell to apply changes: omarchy restart shell"
echo ""
echo "To configure, edit ~/.config/omarchy/shell.json or use:"
echo "  omarchy bar set $PLUGIN_ID symbol BTCUSDT"
echo "  omarchy bar set $PLUGIN_ID timeframe 15m"