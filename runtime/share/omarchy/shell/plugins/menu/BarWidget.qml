import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.menu"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property string customIcon: root.setting("icon", root.setting("text", ""))

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.customIcon !== "" ? root.customIcon : "\ue900"
    fontFamily: root.setting("fontFamily", root.customIcon !== "" ? (root.bar ? root.bar.fontFamily : "JetBrainsMono Nerd Font") : "omarchy")
    fontSize: Number(root.setting("fontSize", root.customIcon !== "" ? 14 : Style.font.body))
    horizontalMargin: Number(root.setting("horizontalMargin", 7.5))
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("omarchy-shell shell toggle omarchy.menu '{\"menu\":\"root\"}'")
    }
  }
}
