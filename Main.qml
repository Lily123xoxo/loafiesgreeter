import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects 1.0

// SDDM requires explicit versioning for imports

Rectangle {
    id: root
    
    property color backgroundColor: "#191011"
    property color borderColor: '#86695b'
    property int borderWidth: 2
    property int fieldRadius: 20
    property int fieldPadding: 20
    property int buttonFontSize: 18
    property int iconSize: 48
    property color textColor: '#e0e0e0'
    property color accentColor: '#f2cbbb'
    property color buttonHoverColor: '#b44549'
    property int highlightFadeOut: 400
    property real iconHoverScale: 1.1
    property int selectedUserIndex: 0

    ListModel { id: errorLog }

    width: Screen.width
    height: Screen.height
    color: backgroundColor

    Image {
        id: loafFrame
        source: "assets/loaf-frame.svg"
        anchors.centerIn: parent
        width: parent.width * 0.9
        height: parent.height * 0.9
        fillMode: Image.PreserveAspectFit
        visible: false
    }

    ColorOverlay {
        id: loafOverlay
        anchors.fill: loafFrame
        source: loafFrame
        color: accentColor
        opacity: 0

        NumberAnimation on opacity { to: 0.5; duration: 1200; easing.type: Easing.InOutQuad }
    }

    Rectangle {

        property int formFieldHeight: height * 0.12

        id: mainPanel

        anchors.horizontalCenter: loafFrame.horizontalCenter
        anchors.verticalCenter: loafFrame.verticalCenter
        anchors.verticalCenterOffset: 200

        width: loafFrame.paintedWidth * 0.6
        height: loafFrame.paintedHeight * 0.47
        radius: 30
        color: backgroundColor
        border.width: borderWidth
        opacity: 0

        NumberAnimation on opacity { to: 1; duration: 1000; easing.type: Easing.InOutQuad }
        border.color: "transparent"

        Rectangle {
            id: username

            anchors.top: mainPanel.top
            anchors.left: mainPanel.left
            anchors.right: consolePanel.left
            anchors.topMargin: fieldPadding
            anchors.leftMargin: fieldPadding
            anchors.rightMargin: fieldPadding

            height: parent.formFieldHeight
            radius: fieldRadius
            border.width: borderWidth
            border.color: usernameField.activeFocus ? accentColor : borderColor
            color: "transparent"

            Behavior on border.color { ColorAnimation { duration: 200 } }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -implicitHeight / 2
                text: " user "
                color: borderColor
                font.pixelSize: 13

                Rectangle {
                    anchors.fill: parent
                    color: backgroundColor
                    z: -1
                }
            }

            TextField {
                id: usernameField

                anchors.fill: parent
                anchors.margins: 5

                text: userModel.data(userModel.index(0, 0), Qt.UserRole + 1)
                Keys.onReturnPressed: passwordField.forceActiveFocus()

                font.pixelSize: 20
                color: activeFocus ? accentColor : "#FFFFFF"
                verticalAlignment: TextInput.AlignVCenter
                background: null

                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        Rectangle {
            id: password

            anchors.top: username.bottom
            anchors.left: mainPanel.left
            anchors.right: consolePanel.left
            anchors.topMargin: fieldPadding
            anchors.leftMargin: fieldPadding
            anchors.rightMargin: fieldPadding

            height: parent.formFieldHeight
            radius: fieldRadius
            border.width: borderWidth
            border.color: passwordField.activeFocus ? accentColor : borderColor
            color: "transparent"

            Behavior on border.color { ColorAnimation { duration: 200 } }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -implicitHeight / 2
                text: " pass "
                color: borderColor
                font.pixelSize: 13

                Rectangle {
                    anchors.fill: parent
                    color: backgroundColor
                    z: -1
                }
            }

            TextField {
                id: passwordField

                anchors.fill: parent
                anchors.margins: 5

                echoMode: TextInput.Password
                Keys.onReturnPressed: login()

                font.pixelSize: 20
                color: activeFocus ? accentColor : "#FFFFFF"
                verticalAlignment: TextInput.AlignVCenter
                background: null

                Behavior on color { ColorAnimation { duration: 200 } }
            }
        } 

        Rectangle {
            id: consolePanel

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: fieldPadding

            width: parent.width * 0.4
            radius: fieldRadius
            border.width: borderWidth
            border.color: borderColor
            color: "transparent"

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -implicitHeight / 2
                text: " sys "
                color: borderColor
                font.pixelSize: 13

                Rectangle {
                    anchors.fill: parent
                    color: backgroundColor
                    z: -1
                }
            }

            Column {
                id: consoleContent
                anchors.bottom: consoleDivider.top
                anchors.bottomMargin: fieldPadding
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: fieldPadding
                anchors.rightMargin: fieldPadding
                spacing: 8

                Text {
                    text: "> @" + (sddm.hostName || "unknown")
                    color: "#ffffff"
                    font.pixelSize: 15
                }

                Text {
                    id: clockText
                    text: "> " + Qt.formatDateTime(new Date(), "dd-MM-yyyy, hh:mm:ss")
                    color: "#ffffff"
                    font.pixelSize: 15

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clockText.text = "> " + Qt.formatDateTime(new Date(), "dd-MM-yyyy, hh:mm:ss")
                    }
                }
            }

            ComboBox {
                id: sessionSelector
                anchors.top: parent.top
                anchors.topMargin: fieldPadding
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: fieldPadding
                anchors.rightMargin: fieldPadding
                height: 40
                model: sessionModel
                textRole: "name"

                    contentItem: Item {
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: "> " + sessionSelector.displayText
                            color: (sessionSelector.activeFocus || sessionSelector.hovered) ? accentColor : "#ffffff"
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
                        border.width: borderWidth
                        border.color: sessionSelector.activeFocus ? accentColor : borderColor
                        radius: 10

                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }

                    indicator: null

                    popup: Popup {
                        y: sessionSelector.height
                        width: sessionSelector.width
                        padding: 4

                        background: Rectangle {
                            color: backgroundColor
                            border.width: borderWidth
                            border.color: borderColor
                            radius: 10
                        }

                        contentItem: ListView {
                            implicitHeight: contentHeight
                            model: sessionSelector.popup.visible ? sessionSelector.delegateModel : null
                            clip: true
                        }
                    }

                    delegate: ItemDelegate {
                        width: sessionSelector.width
                        highlighted: sessionSelector.highlightedIndex === index
                        contentItem: Text {
                            text: "> " + model.name
                            color: (hovered || highlighted) ? buttonHoverColor : "#ffffff"
                            font.pixelSize: 15
                        }
                        background: Rectangle {
                            color: "transparent"
                        }
                    }
                }

            Rectangle {
                id: consoleDivider
                y: password.y + password.height - consolePanel.y
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: borderColor
            }

            Flickable {
                id: consoleFlickable
                anchors.top: consoleDivider.bottom
                anchors.topMargin: fieldPadding
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: fieldPadding
                anchors.rightMargin: fieldPadding
                anchors.bottomMargin: fieldPadding
                contentHeight: consoleLog.height
                clip: true

                Column {
                    id: consoleLog
                    width: parent.width
                    spacing: 4

                    Text {
                        text: "> initialisation complete"
                        color: '#929292'
                        font.pixelSize: 15
                    }

                    Repeater {
                        model: errorLog
                        Text {
                            text: "> " + model.text
                            color: "#ff5555"
                            font.pixelSize: 15
                        }
                    }

                    Text {
                        text: "> hello world"
                        color: '#929292'
                        font.pixelSize: 15
                    }

                    Text {
                        id: cursorText
                        text: "> _"
                        color: '#929292'
                        font.pixelSize: 15

                        Timer {
                            interval: 500
                            running: true
                            repeat: true
                            onTriggered: cursorText.visible = !cursorText.visible
                        }
                    }
                }

                onContentHeightChanged: {
                    contentY = Math.max(0, contentHeight - height)
                }
            }
        }

        Rectangle {
            id: buttonContainer

            anchors.top: password.bottom
            anchors.topMargin: fieldPadding
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: consolePanel.left
            anchors.bottomMargin: fieldPadding
            anchors.leftMargin: fieldPadding
            anchors.rightMargin: fieldPadding

            border.width: borderWidth
            border.color: borderColor
            radius: fieldRadius
            color: "transparent"

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -implicitHeight / 2
                text: " go "
                color: borderColor
                font.pixelSize: 13

                Rectangle {
                    anchors.fill: parent
                    color: backgroundColor
                    z: -1
                }
            }

            RowLayout {
                id: buttonRow
                anchors.fill: parent
                anchors.margins: fieldPadding
                spacing: 10

            IconButton {
                iconSource: "assets/lucide/power.svg"
                label: "shutdown"
                onClicked: powerOff()
            }

            IconButton {
                iconSource: "assets/lucide/restart.svg"
                label: "reboot"
                onClicked: reboot()
            }

            IconButton {
                iconSource: "assets/lucide/sleep.svg"
                label: "sleep"
                onClicked: suspend()
            }

            IconButton {
                iconSource: "assets/lucide/paw-print.svg"
                label: "login"
                onClicked: login()
            }
            }
        }

    }

    Component.onCompleted: {
        if (usernameField.text === "")
            usernameField.forceActiveFocus()
        else
            passwordField.forceActiveFocus()
    }


/* Functions go here */

    function login() {
        errorLog.clear()
        sddm.login(
            usernameField.text,
            passwordField.text,
            sessionSelector.currentIndex
        )
    }

    function selectUser(index) {
        selectedUserIndex = index
    }

    function populateSessions() {
        var sessions = []
        for (var i = 0; i < sessionModel.rowCount(); i++) {
            sessions.push(sessionModel.data(sessionModel.index(i, 0), Qt.UserRole))
        }
        return sessions
    }

    function showError(message) {
        errorLog.append({ text: message })
    }

    function powerOff() {
        sddm.powerOff()
    }

    function reboot() {
        sddm.reboot()
    }

    function suspend() {
        sddm.suspend()
    }

    // Unused
    function hibernate() {
        sddm.hibernate()
    }

    property var errorMessages: [
        "segfault (core dumped)",
        "error: auth returned nullptr",
        "fatal: password mismatch at 0xDEADBEEF",
        "panic: invalid credentials",
        "403 forbidden",
        "err: stack overflow in auth.c:42",
        "SIGTERM: credential process killed",
        "throw new Error('wrong password')",
        "exit code 1: permission denied"
    ]

    Connections {
        target: sddm
        function onLoginSucceeded() {}
        function onLoginFailed() {
            showError(errorMessages[Math.floor(Math.random() * errorMessages.length)])
            passwordField.text = ""
        }
    }
}
