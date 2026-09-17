// TradingView Signal Service for Omarchy
// This service can be run independently to fetch signals and update the bar widget
// via Quickshell IPC or by writing to a shared file

import QtQuick
import Quickshell
import qs.Commons

Service {
    id: root
    moduleName: "io.github.ValoLoco.tradingview-signals.service"

    property string symbol: setting("symbol", "BTCUSDT")
    property string timeframe: setting("timeframe", "15m")
    property int updateInterval: setting("updateInterval", 60000)
    property string webhookPort: setting("webhookPort", "8080")
    property string dataFile: setting("dataFile", "/tmp/tradingview-signals.json")

    // Timer for periodic updates
    Timer {
        interval: updateInterval
        running: true
        repeat: true
        onTriggered: fetchSignal()
    }

    // Webhook server for receiving Pine Script alerts
    // Requires a simple HTTP server - can use Python or Node.js helper
    // For now, we'll use a file-based approach for simplicity

    function fetchSignal() {
        // Option 1: Read from file (written by external script/webhook receiver)
        try {
            var file = new File(dataFile)
            if (file.open(File.ReadOnly)) {
                var content = file.readAll()
                file.close()
                var data = JSON.parse(content)
                if (data.symbol === symbol && data.signal) {
                    emitSignal(data.signal)
                    console.log("Signal updated from file:", data.signal)
                }
            }
        } catch (e) {
            console.log("File read error:", e.message)
        }

        // Option 2: Fetch from TradingView webhook endpoint (if configured)
        // fetchWebhookSignal()
    }

    function fetchWebhookSignal() {
        // Placeholder for HTTP fetch
        // In production, use XMLHttpRequest or a helper process
    }

    function emitSignal(newSignal) {
        // Send signal to the bar widget via Quickshell message bus
        Quickshell.sendMessage({
            module: "io.github.ValoLoco.tradingview-signals",
            action: "updateSignal",
            signal: newSignal
        })
    }

    // Public function to receive webhook data
    function onWebhookReceived(signalData) {
        if (signalData.symbol === symbol) {
            emitSignal(signalData.signal)
        }
    }

    Component.onCompleted: {
        console.log("TradingView Signal Service started for", symbol, timeframe)
        fetchSignal()
    }
}