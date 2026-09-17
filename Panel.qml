import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

BarWidget {
    id: root
    moduleName: "io.github.ValoLoco.tradingview-signals"

    width: 60
    height: barSize

    Rectangle {
        anchors.fill: parent
        color: "#ffff00" // bright yellow
        radius: 4
    }

    Text {
        text: "TV"
        color: "#000000"
        font.pixelSize: Style.font.body
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            console.log("TradingView widget clicked")
            Qt.openUrlExternally("https://www.tradingview.com/")
        }
    }
}