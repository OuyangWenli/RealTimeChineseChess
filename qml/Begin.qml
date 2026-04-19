import QtQuick
import QtQuick.Layouts

Item {
    id: beginRoot
    anchors.fill: parent

    Board {
        id: boardContainer
        anchors.fill: parent

        // 放置动态坐标按钮
        Button {
            logicX: 2
            logicY: 6
            imageName: "JiNeng"
            parentBoard: boardContainer.chessBoardImage
            onClicked: {
                messageDialog.show("敬请期待");
            }
        }

        Button {
            logicX: 6
            logicY: 6
            imageName: "PuTong"
            parentBoard: boardContainer.chessBoardImage
            onClicked: {
                matchStatusText.text = "请输入6位对战码";
                delaySendMatch.stop();
                network.disconnectFromServer();
                matchDialog.visible = true;
            }
        }
    }

    // 原生轻量提示框
    Rectangle {
        id: messageDialog
        width: 300
        height: 150
        color: "white"
        radius: 10
        border.color: "#ccc"
        border.width: 1
        anchors.centerIn: parent
        visible: false

        function show(msg) {
            msgText.text = msg;
            visible = true;
        }

        Text {
            id: msgText
            anchors.centerIn: parent
            font.pixelSize: 20
            color: "#333"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: messageDialog.visible = false
        }
    }

    // 匹配对战弹窗
    Rectangle {
        id: matchDialog
        width: 400
        height: 250
        color: "white"
        radius: 10
        border.color: "#333"
        border.width: 2
        anchors.centerIn: parent
        visible: false

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                id: matchStatusText
                text: "请输入6位对战码"
                font.pixelSize: 22
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                width: 200
                height: 40
                border.color: "#999"
                border.width: 1
                radius: 5
                Layout.alignment: Qt.AlignHCenter

                TextInput {
                    id: codeInput
                    anchors.fill: parent
                    anchors.margins: 5
                    font.pixelSize: 20
                    maximumLength: 6
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    focus: true
                    clip: true
                }
            }

            RowLayout {
                spacing: 20
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    width: 100
                    height: 40
                    color: "#4CAF50"
                    radius: 5
                    Text {
                        anchors.centerIn: parent
                        text: "开始匹配"
                        color: "white"
                        font.pixelSize: 18
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (codeInput.text.length < 6) {
                                matchStatusText.text = "请输入完整的6位码";
                                return;
                            }
                            delaySendMatch.stop();
                            matchStatusText.text = "匹配中...";

                            network.connectToServer("38.55.134.186", 8888, 0);

                            // 延时2000ms等待 Socket 连上
                            delaySendMatch.start();
                        }
                    }
                }

                Rectangle {
                    width: 100
                    height: 40
                    color: "#f44336"
                    radius: 5
                    Text {
                        anchors.centerIn: parent
                        text: "取消"
                        color: "white"
                        font.pixelSize: 18
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            matchDialog.visible = false;
                            delaySendMatch.stop();
                            matchStatusText.text = "请输入6位对战码";
                            network.disconnectFromServer();
                        }
                    }
                }
            }
        }

        Timer {
            id: delaySendMatch
            interval: 2000
            onTriggered: {
                network.sendMatch(codeInput.text);
            }
        }

        Timer {
            id: enterGameTimer
            interval: 1500
            onTriggered: {
                matchDialog.visible = false;
                window.page = "fighting";
            }
        }

        Connections {
            target: network
            function onMatchSuccess() {
                matchStatusText.text = "匹配成功！";
                enterGameTimer.start();
            }
            function onMatchFailed(msg) {
                matchStatusText.text = msg;
            }
        }
    }
}


