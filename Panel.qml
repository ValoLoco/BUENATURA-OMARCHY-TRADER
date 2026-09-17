import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

BarWidget {
    id: root
    moduleName: "io.github.ValoLoco.tradingview-signals"

    // Default signal state
    property string signal: "HOLD" // BUY, SELL, HOLD
    property color signalColor: "#ffff00" // Yellow for HOLD
    property string tooltipText: "Click to open TradingView"

    // Update color based on signal
    onSignal: {
        if (signal === "BUY")
            signalColor = "#00ff00" // Green
        else if (signal === "SELL")
            signalColor = "#ff0000" // Red
        else
            signalColor = "#ffff00" // Yellow
    }

    // Define the size
    implicitWidth: 80
    implicitHeight: barSize

    background: Rectangle {
        color: root.signalColor
        radius: 4
    }

    Text {
        id: signalLabel
        text: root.signal
        color: "#000000"
        font.pixelSize: Style.font.body
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            // For now, just show a notification or open TradingView in browser
            // In a real implementation, you might open a specific TradingView chart or alert page
            Qt.openUrlExternally("https://www.tradingview.com/")
        }
        onEntered: if (root.bar) root.bar.showTooltip(root, root.tooltipText)
        onExited: if (root.bar) root.bar.hideTooltip(root)
    }

    // Optional: Add a tooltip with more details
    tooltip: root.tooltipText
}
