import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3

Item {
    id: root
    width: parent ? parent.width : implicitWidth
    height: units.gu(5)

    property alias text: label.text
    property alias fontSize: label.font.pixelSize
    property alias fontBold: label.font.bold
    property bool enabled: true
    signal clicked

    // Icon properties
    property string iconName: ""    // Built-in symbolic icon name (e.g., "add", "edit", "delete")
    property string iconSource: ""  // Path to custom icon image file
    property color iconColor: root.fgColor
    property real iconSize: units.gu(1.5)
    property bool iconBold: false
    property int spacing: units.gu(1)

    // Customizable colors (defaults no longer tied to AppConst)
    property color bgColor: enabled ? "#2980b9" : "#bdc3c7"      // Blue vs. gray fallback
    property color fgColor: "#ffffff"                           // White text
    property color hoverColor: "#3498db"                        // Lighter blue
    property color borderColor: "transparent"
    property int radius: units.gu(0.8)

    Rectangle {
        id: buttonRect
        anchors.fill: parent
        anchors.margins: units.gu(0.25)
        radius: root.radius
        color: mouseArea.containsMouse ? root.hoverColor : root.bgColor
        border.color: root.borderColor

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: root.spacing

            Icon {
                id: builtinIcon
                visible: root.iconName !== ""
                name: root.iconName
                width: visible ? (root.iconBold ? root.iconSize * 1.2 : root.iconSize) : 0
                height: visible ? (root.iconBold ? root.iconSize * 1.2 : root.iconSize) : 0
                anchors.verticalCenter: parent.verticalCenter
                color: root.iconBold ? Qt.darker(root.iconColor, 0.8) : root.iconColor
            }

            Image {
                id: customIcon
                visible: root.iconSource !== "" && root.iconName === ""
                source: root.iconSource
                width: visible ? (root.iconBold ? root.iconSize * 1.2 : root.iconSize) : 0
                height: visible ? (root.iconBold ? root.iconSize * 1.2 : root.iconSize) : 0
                anchors.verticalCenter: parent.verticalCenter
                opacity: root.iconBold ? 1.0 : 0.9
            }

            Text {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                color: root.fgColor
                font.bold: false
                font.pixelSize: units.gu(1.5)
                visible: text !== ""
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.clicked()
        }
    }
}
