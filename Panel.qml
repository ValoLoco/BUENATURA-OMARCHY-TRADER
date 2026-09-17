import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

BarWidget {
    id: root
    moduleName: "io.github.ValoLoco.tradingview-signals"

    property string signal: setting("signal", "HOLD")
    property string symbol: setting("symbol", "BTCUSDT")
    property string timeframe: setting("timeframe", "15m")
    property color buyColor: setting("buyColor", "#00ff00")
    property color sellColor: setting("sellColor", "#ff0000")
    property color holdColor: setting("holdColor", "#ffff00")

    readonly property color signalColor: {
        if (signal === "BUY") return buyColor
        else if (signal === "SELL") return sellColor
        else return holdColor
    }

    implicitWidth: 60
    implicitHeight: barSize

    Rectangle {
        anchors.fill: parent
        color: root.signalColor
        radius: 4
    }

    Text {
        text: root.signal
        color: "#000000"
        font.pixelSize: Style.font.body
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Qt.openUrlExternally("https://www.tradingview.com/chart/?symbol=" + root.symbol)
        }
        onEntered: if (root.bar) root.bar.showTooltip(root, "TradingView: " + root.symbol + " " + root.timeframe + " — " + root.signal)
        onExited: if (root.bar) root.bar.hideTooltip(root)
    }
}