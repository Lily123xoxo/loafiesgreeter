import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.0

// SDDM defaults to Qt5 which requires explicit versioning for imports

/* TODO:
 * - Add nums lock preview + warning when on. Grab icon from Lucide.
 * - Wire theme config to greater loafies qml theme. If QML theme updated:
 *      - matugen generates theme from new wallpaper via loafies theme -> trigger/hook to update sddm for to same themed matugens for next login.
 *      - theme.conf keys [at this time]: backgroundColor, borderColor, accentColor, buttonHoverColor
 *      - some trigger or hook needs to know to update the keys in theme.conf and with the correct mappings (will require testing to find good fits)
 *      - read via config.<key> instead of hardcoded hex values
*/

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: backgroundColor

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
                KeyNavigation.tab: passwordField
                KeyNavigation.backtab: sleepBtn

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
                KeyNavigation.tab: loginBtn
                KeyNavigation.backtab: usernameField

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
                anchors.top: userSelector.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: fieldPadding
                anchors.rightMargin: fieldPadding
                spacing: 8

                Text {
                    text: "> @" + (sddm.hostName ? sddm.hostName : "unknown")
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

            SelectorComboBox {
                id: sessionSelector
                anchors.top: parent.top
                anchors.topMargin: fieldPadding
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: fieldPadding
                anchors.rightMargin: fieldPadding
                model: sessionModel
                textRole: "name"
                KeyNavigation.tab: userSelector
                KeyNavigation.backtab: loginBtn
            }

            SelectorComboBox {
                id: userSelector
                anchors.top: sessionSelector.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: fieldPadding
                anchors.rightMargin: fieldPadding
                model: userModel
                textRole: "name"
                KeyNavigation.tab: shutdownBtn
                KeyNavigation.backtab: sessionSelector

                property bool initialized: false
                onCurrentIndexChanged: {
                    var userName = userModel.data(userModel.index(currentIndex, 0), Qt.UserRole + 1)
                    usernameField.text = userName
                    selectedUserIndex = currentIndex
                    if (initialized) {
                        passwordField.text = ""
                        passwordField.forceActiveFocus()
                    }
                }
                Component.onCompleted: initialized = true
            }

            Rectangle {
                id: consoleDivider
                anchors.top: consoleContent.bottom
                anchors.topMargin: fieldPadding
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
                        text: "> hello world"
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
                id: shutdownBtn
                iconSource: "assets/lucide/power.svg"
                label: "shutdown"
                onClicked: powerOff()
                KeyNavigation.tab: rebootBtn
                KeyNavigation.backtab: userSelector
            }

            IconButton {
                id: rebootBtn
                iconSource: "assets/lucide/restart.svg"
                label: "reboot"
                onClicked: reboot()
                KeyNavigation.tab: sleepBtn
                KeyNavigation.backtab: shutdownBtn
            }

            IconButton {
                id: sleepBtn
                iconSource: "assets/lucide/sleep.svg"
                label: "sleep"
                onClicked: suspend()
                KeyNavigation.tab: usernameField
                KeyNavigation.backtab: rebootBtn
            }

            IconButton {
                id: loginBtn
                iconSource: "assets/lucide/paw-print.svg"
                label: "login"
                onClicked: login()
                KeyNavigation.tab: sessionSelector
                KeyNavigation.backtab: passwordField
            }
            }
        }

    }

/* Functions go here */

    Connections {
            target: sddm
            function onLoginSucceeded() {}
            function onLoginFailed() {
                showError(errorMessages[Math.floor(Math.random() * errorMessages.length)])
                passwordField.text = ""
            }
        }

    // Try to prefill session and user fields from last login data
    Component.onCompleted: {
        var lastUserIdx = userModel.lastIndex
        if (lastUserIdx >= 0 && lastUserIdx < userModel.count)
            userSelector.currentIndex = lastUserIdx

        var lastSessionIdx = sessionModel.lastIndex
        if (lastSessionIdx >= 0 && lastSessionIdx < sessionModel.count)
            sessionSelector.currentIndex = lastSessionIdx

        if (usernameField.text === "")
            usernameField.forceActiveFocus()
        else
            passwordField.forceActiveFocus()
    }

    function login() {
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
}
