import QtQuick
import Quickshell

PanelWindow {
  anchors.top: true
  anchors.right: true
  implicitWidth: 220
  implicitHeight: 32

  Rectangle {
    anchors.fill: parent
    radius: 6
    color: "#1e1e2e"

    Text {
      anchors.centerIn: parent
      text: "NQ | SIGNAL GATEWAY OFFLINE"
      color: "#f38ba8"
      font.pixelSize: 12
    }
  }
}
