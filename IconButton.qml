import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects 1.0

Rectangle {
    id: btnRoot
    property string iconSource
    property string label
    signal clicked()

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: root.fieldRadius
    border.width: root.borderWidth
    border.color: "transparent"
    color: "transparent"

    property real _iconDisplaySize: root.iconSize

    states: State {
        name: "hovered"; when: mouseArea.containsMouse
        PropertyChanges { target: btnRoot; border.color: root.buttonHoverColor; _iconDisplaySize: root.iconSize * root.iconHoverScale }
    }

    transitions: [
        Transition {
            from: ""; to: "hovered"
            ColorAnimation { duration: 0 }
            NumberAnimation { property: "_iconDisplaySize"; duration: 0 }
        },
        Transition {
            from: "hovered"; to: ""
            ColorAnimation { duration: root.highlightFadeOut }
            NumberAnimation { property: "_iconDisplaySize"; duration: 0 }
        }
    ]

    Image {
        id: icon
        source: iconSource
        anchors.centerIn: parent
        width: _iconDisplaySize
        height: _iconDisplaySize
        sourceSize: Qt.size(root.iconSize * root.iconHoverScale, root.iconSize * root.iconHoverScale)
        fillMode: Image.PreserveAspectFit
        visible: false
    }

    ColorOverlay {
        id: overlay
        anchors.fill: icon
        source: icon
        color: root.textColor
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        text: label
        color: root.textColor
        font.pixelSize: root.buttonFontSize
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: btnRoot.clicked()
    }
}
