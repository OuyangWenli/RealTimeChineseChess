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
                messageDialog.show(300,150,"敬请期待");
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

        Button {
            logicX: 6
            logicY: 3
            imageName: "Introduction"
            parentBoard: boardContainer.chessBoardImage
            onClicked: {
                messageDialog.show(800,350,"实时对战象棋\n
完全摒弃“你拍一我拍一”的老旧回合制定式\n
所有棋子的移动共享指挥点数，红黑双方分别拥有一个随时间逐渐恢复的指挥点槽\n
将帅移动不需要消耗指挥点\n
每个棋子有自己的体力点数，行动需要消耗体力，兵、士、象体力充足时可以连走两步\n
将帅见面时可直接使用将吃掉对方的将");
            }
        }

        Button {
            logicX: 2
            logicY: 3
            imageName: "Developer"
            parentBoard: boardContainer.chessBoardImage
            onClicked: {
                messageDialog.show(500,250,"音乐资源：爱给网小呆瓜_26，爱给网子沐mumu\n
图片资源：豆包\n
界面设计：艾 喝茉莉花茶\n
后端开发：艾 喝茉莉花茶\n
测试：艾 喝茉莉花茶、Ten、醉乃脓忘笛、秋前盛夏");
            }
        }
    }

    // 消息提示弹窗，提示信息后点击任意位置即可关闭
    Rectangle {
        id: messageDialog
        width: 0
        height: 0
        color: "white"
        radius: 10
        border.color: '#b5b3b3'
        border.width: 1
        anchors.centerIn: parent
        visible: false

        Text {
            id: msgText
            anchors.centerIn: parent
            font.pixelSize: 20
            color: '#353535'
        }
        MouseArea {
            anchors.fill: parent
            onClicked: messageDialog.visible = false
        }
        
        function show(w,h,msg) {
            messageDialog.width = w;
            messageDialog.height = h;
            msgText.text = msg;
            visible = true;
        }
    }

    // 匹配对战弹窗
    Rectangle {
        id: matchDialog
        width: 400
        height: 250
        color: '#e0e1e4'
        radius: 10
        border.color: '#f1f1f1'
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
                border.color: '#e1dfdf'
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

                            network.connectToServer("chess.ouyangwenli.fun", 8888, 0);

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
            interval: 1500 // 连接后延迟1500ms发送匹配请求，避免服务器还没来得及处理连接就发匹配请求导致的错误
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


