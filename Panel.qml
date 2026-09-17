import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import QtQuick.Controls 2.15 as Controls

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
    property string chartUrlBase: setting("chartUrlBase", "https://www.tradingview.com/chart/")

    // Derived properties
    readonly property color signalColor: {
        switch (signal) {
            case "BUY": return buyColor
            case "SELL": return sellColor
            default: return holdColor
        }
    }

    property string tooltipText: "TradingView: " + symbol + " " + timeframe + " — " + signal
    property string chartUrl: chartUrlBase + "?symbol=" + symbol + "&interval=" + timeframe

    // Timer for periodic updates (placeholder for real data source)
    Timer {
        id: updateTimer
        interval: updateInterval
        running: true
        repeat: true
        onTriggered: {
            // Placeholder: In production, fetch from Pine Script webhook, TradingView API, or local file
            // updateSignal()
        }
    }

    // Dynamic width based on text and icon
    readonly property int minWidth: 70
    readonly property int maxWidth: 120
    readonly property int iconSize: 20

    implicitWidth: Math.max(minWidth, Math.min(maxWidth, 
        iconSize + Style.spacing.controlPaddingX * 2 + 
        signalLabel.implicitWidth))
    implicitHeight: barSize

    // Popup for settings
    Popup {
        id: settingsPopup
        width: 200
        height: 250
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Label { text: "Symbol"; Layout.alignment: Qt.AlignLeft }
            TextField {
                id: symbolField
                text: root.symbol
                Layout.fillWidth: true
                onAccepted: root.symbol = text
            }
            Label { text: "Timeframe"; Layout.alignment: Qt.AlignLeft }
            TextField {
                id: timeframeField
                text: root.timeframe
                Layout.fillWidth: true
                onAccepted: root.timeframe = text
            }
            Label { text: "Buy Color"; Layout.alignment: Qt.AlignLeft }
            ColorPicker {
                id: buyPicker
                color: root.buyColor
                Layout.fillWidth: true
                onColorChanged: root.buyColor = color
            }
            Label { text: "Sell Color"; Layout.alignment: Qt.AlignLeft }
            ColorPicker {
                id: sellPicker
                color: root.sellColor
                Layout.fillWidth: true
                onColorChanged: root.sellColor = color
            }
            Label { text: "Hold Color"; Layout.alignment: Qt.AlignLeft }
            ColorPicker {
                id: holdPicker
                color: root.holdColor
                Layout.fillWidth: true
                onColorChanged: root.holdColor = color
            }
            Button {
                text: "Save"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    // Persist settings via shell.json? For now just update properties; could call omarchy bar set
                    // We'll update properties; they are bound to settings already via property binding? Actually property reads from setting() only once.
                    // To persist, we need to update shell.json via omarchy command. We'll do a simple approach: call omarchy bar set for each.
                    // We'll execute via Qt.invokeLater to avoid blocking.
                    Qt.invokeLater(function() {
                        var cmd = "omarchy bar set " + root.moduleName + " symbol \"" + symbolField.text + "\"";
                        var proc = Qt.createQmlObject('import QtQuick 2.15; QtObject { function exec(cmd) { var proc = Qt.createProcess("sh"); proc.args = ["-c", cmd]; proc.start(); } }', root, "cmdExecutor");
                        proc.exec(cmd);
                    });
                    settingsPopup.close();
                }
            }
        }
    }

    // Background and icon
    Rectangle {
        id: bgRect
        anchors.fill: parent
        color: root.signalColor
        radius: 4
        opacity: 0.9

        // Pulse animation on signal change
        SequentialAnimation on opacity {
            running: false
            NumberAnimation { from: 0.9; to: 1.0; duration: 150; easing: Easing.OutCubic }
            NumberAnimation { from: 1.0; to: 0.9; duration: 150; easing: Easing.InCubic }
            loops: 2
        }
    }

    // Icon (unicode chart symbol)
    Text {
        id: iconText
        text: "📈" // chart increasing
        font.pixelSize: iconSize
        color: "#000000"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Style.spacing.controlPaddingX
    }

    // Signal text
    Text {
        id: signalLabel
        text: root.signal
        color: "#000000"
        font.pixelSize: Style.font.body
        font.weight: Font.Medium
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: iconText.right
        anchors.leftMargin: Style.spacing.controlPaddingX / 2
        elide: Text.ElideRight
        width: parent.width - iconText.width - Style.spacing.controlPaddingX * 2 - iconSize
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // Left click: open TradingView chart
        onClicked: {
            if (mouse.button === Qt.LeftButton) {
                Qt.openUrlExternally(root.chartUrl)
            }
        }
        // Right click or long press: open settings popup
        onPressed: {
            if (mouse.button === Qt.RightButton) {
                settingsPopup.open();
                mouse.accepted = true;
            }
        }
        onPressAndHold: {
            settingsPopup.open();
            mouse.accepted = true;
        }
        onEntered: if (root.bar) root.bar.showTooltip(root, root.tooltipText)
        onExited: if (root.bar) root.bar.hideTooltip(root)
    }

    // Tooltip
    tooltip: root.tooltipText
}