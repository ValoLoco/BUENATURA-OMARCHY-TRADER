import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

BarWidget {
    id: root
    moduleName: "io.github.ValoLoco.tradingview-signals"

    // Configuration properties (can be overridden via shell.json settings)
    property string signal: setting("signal", "HOLD")
    property string symbol: setting("symbol", "BTCUSDT")
    property string timeframe: setting("timeframe", "15m")
    property color buyColor: setting("buyColor", "#00ff00")
    property color sellColor: setting("sellColor", "#ff0000")
    property color holdColor: setting("holdColor", "#ffff00")
    property int updateInterval: setting("updateInterval", 60000) // ms

    readonly property color signalColor: {
        switch (signal) {
            case "BUY": return buyColor
            case "SELL": return sellColor
            default: return holdColor
        }
    }

    property string tooltipText: "TradingView: " + symbol + " " + timeframe + " — " + signal

    // Timer for periodic updates (placeholder for real data source)
    Timer {
        interval: updateInterval
        running: true
        repeat: true
        onTriggered: {
            // Placeholder: In production, fetch from Pine Script webhook, TradingView API, or local file
            // updateSignal()
        }
    }

    // Dynamic width based on text
    readonly property int minWidth: 70
    readonly property int maxWidth: 120

    implicitWidth: Math.max(minWidth, Math.min(maxWidth, signalLabel.implicitWidth + Style.spacing.controlPaddingX * 2))
    implicitHeight: barSize

    // Visual indicator
    Rectangle {
        id: bgRect
        anchors.fill: parent
        color: root.signalColor
        radius: 4
        opacity: 0.9

        // Pulse animation on signal change
        SequentialAnimation on opacity {
            running: false
            NumberAnimation { from: 0.9; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
            NumberAnimation { from: 1.0; to: 0.9; duration: 150; easing.type: Easing.InQuad }
            loops: 2
        }
    }

    // Signal text
    Text {
        id: signalLabel
        text: root.signal
        color: "#000000"
        font.pixelSize: Style.font.body
        font.weight: Font.Medium
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        width: parent.width - Style.spacing.controlPaddingX * 2
    }

    // Small indicator dot for visual emphasis
    Rectangle {
        width: 6
        height: 6
        radius: 3
        color: "#000000"
        opacity: 0.5
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        visible: signal !== "HOLD"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            // Left click: open TradingView chart for the symbol
            Qt.openUrlExternally("https://www.tradingview.com/chart/?symbol=" + symbol)
        }
        onPressAndHold: {
            // Long press: open settings or show detailed menu
            showContextMenu()
        }
        onEntered: if (root.bar) root.bar.showTooltip(root, root.tooltipText)
        onExited: if (root.bar) root.bar.hideTooltip(root)
    }

    // Context menu for quick actions
    Menu {
        id: contextMenu
        MenuItem {
            text: "Open TradingView Chart"
            onTriggered: Qt.openUrlExternally("https://www.tradingview.com/chart/?symbol=" + symbol)
        }
        MenuItem {
            text: "Copy Symbol"
            onTriggered: Qt.clipboard.copy(symbol)
        }
        MenuItem {
            text: "Force Update"
            onTriggered: {
                // trigger manual update
                console.log("Manual update triggered")
            }
        }
        MenuSeparator { }
        MenuItem {
            text: "Configure..."
            onTriggered: {
                // Could open a settings dialog
                console.log("Settings requested")
            }
        }
    }

    function showContextMenu() {
        contextMenu.popup()
    }

    function updateSignal(newSignal) {
        if (newSignal !== signal) {
            signal = newSignal
            bgRect.opacity = 0.9
            // Trigger pulse animation
            var anim = bgRect.opacity
        }
    }

    // Expose update function for external triggers (e.g., from a service)
    Connections {
        target: Quickshell
        onMessageReceived: {
            if (message.module === moduleName && message.action === "updateSignal") {
                updateSignal(message.signal)
            }
        }
    }
}