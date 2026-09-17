import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

BarWidget {
    id: root
    moduleName: "io.github.ValoLoco.tradingview-signals"

    Console.log("TradingView Signals plugin loaded")

    property string signal: setting("signal", "HOLD")
    property string symbol: setting("symbol", "NQ1")
    property string timeframe: setting("timeframe", "5m")
    property color buyColor: setting("buyColor", "#00ff00")
    property color sellColor: setting("sellColor", "#ff0000")
    property color holdColor: setting("holdColor", "#ffff00")

    readonly property color signalColor: {
        if (signal === "BUY") return buyColor
        else if (signal === "SELL") return sellColor
        else return holdColor
    }

    implicitWidth: 100
    implicitHeight: barSize

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.signalColor
        radius: 4
    }

    // TradingView logo image (try to load from web, fallback to text)
    Image {
        id: logoImage
        source: "https://www.tradingview.com/favicon.ico"
        anchors.centerIn: parent
        width: 20
        height: 20
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        cache: false
        onStatusChanged: {
            if (status === Image.Error) {
                // If image fails to load, show fallback text
                fallbackText.visible = true
                logoImage.visible = false
            }
        }
    }

    Text {
        id: fallbackText
        text: "TV"
        color: "#ffffff"
        font.pixelSize: Style.font.body
        anchors.centerIn: parent
        visible: false
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            console.log("TradingView widget clicked")
            Qt.openUrlExternally("https://www.tradingview.com/chart/?symbol=" + root.symbol + "&interval=" + root.timeframe)
        }
        onEntered: if (root.bar) root.bar.showTooltip(root, "TradingView: " + root.symbol + " " + root.timeframe + " — " + root.signal)
        onExited: if (root.bar) root.bar.hideTooltip(root)
    }

    // Update background color when signal changes
    onSignal: background.color = root.signalColor
}