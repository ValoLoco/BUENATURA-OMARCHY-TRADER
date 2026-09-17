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

    implicitWidth: 120
    implicitHeight: barSize

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.signalColor
        radius: 4
        border.width: 2
        border.color: "#000000"
    }

    // TradingView logo image (try to load from web, fallback to text)
    Image {
        id: logoImage
        source: "https://www.tradingview.com/favicon.ico"
        anchors.centerIn: parent
        width: 24
        height: 24
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
        color: "#000000"
        font.pixelSize: Style.font.body
        anchors.centerIn: parent
        visible: false
    }

    // Signal text (optional, could show BUY/SELL/HOLD)
    Text {
        id: signalText
        text: root.signal
        color: "#000000"
        font.pixelSize: Style.font.body
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 4
        visible: root.signal !== "HOLD"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // Left click: open TradingView chart
        onClicked: {
            if (mouse.button === Qt.LeftButton) {
                console.log("TradingView widget left-clicked")
                Qt.openUrlExternally("https://www.tradingview.com/chart/?symbol=" + root.symbol + "&interval=" + root.timeframe)
            }
        }
        // Right click: open settings popup
        onPressed: {
            if (mouse.button === Qt.RightButton) {
                settingsPopup.open()
                mouse.accepted = true
            }
        }
        onEntered: if (root.bar) root.bar.showTooltip(root, "TradingView: " + root.symbol + " " + root.timeframe + " — " + root.signal)
        onExited: if (root.bar) root.bar.hideTooltip(root)
    }

    // Popup for settings
    Popup {
        id: settingsPopup
        width: 300
        height: 350
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            Label { text: "TradingView Signals Settings"; font.pixelSize: Style.font.titleMedium; Layout.alignment: Qt.AlignHCenter }

            Label { text: "Symbol"; Layout.alignment: Qt.AlignLeft }
            TextField {
                id: symbolField
                text: root.symbol
                Layout.fillWidth: true
                onAccepted: root.symbol = text
            }
            Label { text: "Timeframe (e.g., 5m, 1h, 1d)"; Layout.alignment: Qt.AlignLeft }
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
                text: "Save and Apply"
                Layout.alignment: Qt.AlignHCenter
                enabled: true
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

    // Update background color when signal changes
    onSignal: background.color = root.signalColor
}