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
    property string dataFile: setting("dataFile", "/tmp/tradingview-signals.json")

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

    // Timer to read signal data from file
    Timer {
        id: dataTimer
        interval: root.updateInterval
        running: true
        repeat: true
        onTriggered: readSignalData()
    }

    function readSignalData() {
        try {
            var file = new File(root.dataFile)
            if (!file.exists) {
                console.log("Data file does not exist:", root.dataFile)
                return
            }
            if (!file.open(File.ReadOnly)) {
                console.log("Cannot open data file for reading:", root.dataFile)
                return
            }
            var content = file.readAll()
            file.close()
            if (!content) {
                console.log("Empty data file")
                return
            }
            var data = JSON.parse(content)
            // Validate symbol matches our configured symbol (optional)
            if (data.symbol && data.symbol !== root.symbol) {
                // Ignore signals for other symbols
                return
            }
            if (data.signal && ["BUY", "SELL", "HOLD"].includes(data.signal)) {
                if (data.signal !== root.signal) {
                    root.signal = data.signal
                    // Trigger pulse animation via opacity
                    bgRect.opacity = 0.9
                }
            }
        } catch (e) {
            console.log("Error reading signal data:", e.message)
        }
    }

    // Dynamic width based on text and icon
    readonly property int minWidth: 100 // increased for visibility
    readonly property int maxWidth: 140
    readonly property int iconSize: 20

    implicitWidth: Math.max(minWidth, Math.min(maxWidth, 
        iconSize + Style.spacing.controlPaddingX * 2 + 
        signalLabel.implicitWidth))
    implicitHeight: barSize

    // Popup for settings
    Popup {
        id: settingsPopup
        width: 220
        height: 260
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
                    // Persist settings via omarchy bar set commands
                    Qt.invokeLater(function() {
                        // Symbol
                        var cmd1 = "omarchy bar set " + root.moduleName + " symbol \\\"" + symbolField.text + "\\\"";
                        var proc1 = Qt.createQmlObject('import QtQuick 2.15; QtObject { function exec(cmd) { var proc = Qt.createProcess("sh"); proc.args = ["-c", cmd]; proc.start(); } }', root, "cmdExecutor1");
                        proc1.exec(cmd1);
                        // Timeframe
                        var cmd2 = "omarchy bar set " + root.moduleName + " timeframe \\\"" + timeframeField.text + "\\\"";
                        var proc2 = Qt.createQmlObject('import QtQuick 2.15; QtObject { function exec(cmd) { var proc = Qt.createProcess("sh"); proc.args = ["-c", cmd]; proc.start(); } }', root, "cmdExecutor2");
                        proc2.exec(cmd2);
                        // Buy Color
                        var cmd3 = "omarchy bar set " + root.moduleName + " buyColor \\\"" + buyPicker.color + "\\\"";
                        var proc3 = Qt.createQmlObject('import QtQuick 2.15; QtObject { function exec(cmd) { var proc = Qt.createProcess("sh"); proc.args = ["-c", cmd]; proc.start(); } }', root, "cmdExecutor3");
                        proc3.exec(cmd3);
                        // Sell Color
                        var cmd4 = "omarchy bar set " + root.moduleName + " sellColor \\\"" + sellPicker.color + "\\\"";
                        var proc4 = Qt.createQmlObject('import QtQuick 2.15; QtObject { function exec(cmd) { var proc = Qt.createProcess("sh"); proc.args = ["-c", cmd]; proc.start(); } }', root, "cmdExecutor4");
                        proc4.exec(cmd4);
                        // Hold Color
                        var cmd5 = "omarchy bar set " + root.moduleName + " holdColor \\\"" + holdPicker.color + "\\\"";
                        var proc5 = Qt.createQmlObject('import QtQuick 2.15; QtObject { function exec(cmd) { var proc = Qt.createProcess("sh"); proc.args = ["-c", cmd]; proc.start(); } }', root, "cmdExecutor5");
                        proc5.exec(cmd5);
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
        border.color: "#ffffff"
        border.width: 1

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

    // Initialize: read data immediately on startup
    Component.onCompleted: {
        readSignalData()
    }
}