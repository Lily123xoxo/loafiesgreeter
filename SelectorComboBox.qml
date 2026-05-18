import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: comboRoot
    height: 40

    contentItem: Item {
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "> " + comboRoot.displayText
            color: (comboRoot.activeFocus || comboRoot.hovered) ? root.accentColor : "#ffffff"
            font.pixelSize: 15

            Behavior on color { ColorAnimation { duration: 200 } }
        }
        Image {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            source: "assets/lucide/chevron-down.svg"
            width: 16
            height: 16
            sourceSize: Qt.size(16, 16)
            fillMode: Image.PreserveAspectFit
        }
    }

    background: Rectangle {
        color: "transparent"
        border.width: root.borderWidth
        border.color: comboRoot.activeFocus ? root.accentColor : root.borderColor
        radius: 10

        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    indicator: null

    popup: Popup {
        y: comboRoot.height
        width: comboRoot.width
        padding: 4

        background: Rectangle {
            color: root.backgroundColor
            border.width: root.borderWidth
            border.color: root.borderColor
            radius: 10
        }

        contentItem: ListView {
            implicitHeight: contentHeight
            model: comboRoot.popup.visible ? comboRoot.delegateModel : null
            clip: true
        }
    }

    delegate: ItemDelegate {
        width: comboRoot.width
        highlighted: comboRoot.highlightedIndex === index
        contentItem: Text {
            text: "> " + model.name
            color: (hovered || highlighted) ? root.buttonHoverColor : "#ffffff"
            font.pixelSize: 15
        }
        background: Rectangle {
            color: "transparent"
        }
    }
}
