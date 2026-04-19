//对战界面
import QtQuick

Item {
    id: fightingRoot
    anchors.fill: parent

    rotation: network.localColor === 1 ? 180 : 0

    onVisibleChanged: {
        if (visible) {
            globalRule.startRecovery() // 当显示这页时开始积攒点数
        } else {
            globalRule.stopRecovery() // 切出时冻结
        }
    }

    Board {
        id: boardContainer
        anchors.fill: parent

        //将帅单独初始化，把两个指挥点的行动力回复颜色设置为透明
        Piece{
            logicX: 4;
            logicY: 0;
            pieceName: "Black_G";
            color: "black";
            parentBoard: boardContainer.chessBoardImage
            oneAPColor: '#026ec0'
        }
        Piece{
            logicX: 4;
            logicY: 9;
            pieceName: "Red_G";
            color: "red";
            parentBoard: boardContainer.chessBoardImage
            oneAPColor: '#026ec0'
        }

        // 黑方
        Piece { logicX: 0; logicY: 0; pieceName: "Black_R"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 1; logicY: 0; pieceName: "Black_H"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 2; logicY: 0; pieceName: "Black_E"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 3; logicY: 0; pieceName: "Black_A"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 5; logicY: 0; pieceName: "Black_A"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 6; logicY: 0; pieceName: "Black_E"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 7; logicY: 0; pieceName: "Black_H"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 8; logicY: 0; pieceName: "Black_R"; color: "black"; parentBoard: boardContainer.chessBoardImage }

        Piece { logicX: 1; logicY: 2; pieceName: "Black_C"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 7; logicY: 2; pieceName: "Black_C"; color: "black"; parentBoard: boardContainer.chessBoardImage }

        Piece { logicX: 0; logicY: 3; pieceName: "Black_S"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 2; logicY: 3; pieceName: "Black_S"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 4; logicY: 3; pieceName: "Black_S"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 6; logicY: 3; pieceName: "Black_S"; color: "black"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 8; logicY: 3; pieceName: "Black_S"; color: "black"; parentBoard: boardContainer.chessBoardImage }

        // 红方
        Piece { logicX: 0; logicY: 9; pieceName: "Red_R"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 1; logicY: 9; pieceName: "Red_H"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 2; logicY: 9; pieceName: "Red_E"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 3; logicY: 9; pieceName: "Red_A"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 5; logicY: 9; pieceName: "Red_A"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 6; logicY: 9; pieceName: "Red_E"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 7; logicY: 9; pieceName: "Red_H"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 8; logicY: 9; pieceName: "Red_R"; color: "red"; parentBoard: boardContainer.chessBoardImage }

        Piece { logicX: 1; logicY: 7; pieceName: "Red_C"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 7; logicY: 7; pieceName: "Red_C"; color: "red"; parentBoard: boardContainer.chessBoardImage }

        Piece { logicX: 0; logicY: 6; pieceName: "Red_S"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 2; logicY: 6; pieceName: "Red_S"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 4; logicY: 6; pieceName: "Red_S"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 6; logicY: 6; pieceName: "Red_S"; color: "red"; parentBoard: boardContainer.chessBoardImage }
        Piece { logicX: 8; logicY: 6; pieceName: "Red_S"; color: "red"; parentBoard: boardContainer.chessBoardImage }
    }

    // 放置在屏幕左边给红方看的进度条
    Dynamic { isRed: true; anchors.left: parent.left; anchors.leftMargin: 150; anchors.verticalCenter: parent.verticalCenter }

    // 放置在屏幕右侧给黑方面对自己的反向进度条
    Dynamic { isRed: false; anchors.right: parent.right; anchors.rightMargin: 150; anchors.verticalCenter: parent.verticalCenter }

    Connections {
        target: board
        function onGameOver(winner) {
            gameOverLayer.winner = winner;
            gameOverLayer.visible = true;
            globalRule.stopRecovery();
        }
    }

    Rectangle {
        id: gameOverLayer
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: false
        z: 9999

        property int winner: 0

        MouseArea {
            anchors.fill: parent
        }

        Rectangle {
            anchors.centerIn: parent
            width: 300
            height: 200
            color: "white"
            radius: 10
            rotation: network.localColor === 1 ? 180 : 0 // 添加旋转，确保黑方胜利弹窗不倒置

            Text {
                id: resultText
                anchors.top: parent.top
                anchors.topMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter
                text: gameOverLayer.winner === 1 ? "黑方胜利！" : "红方胜利！"
                font.pixelSize: 32
                font.bold: true
                color: gameOverLayer.winner === 1 ? "black" : "red"
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30
                anchors.horizontalCenter: parent.horizontalCenter
                width: 160
                height: 50
                color: "#4CAF50"
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: "返回主界面"
                    font.pixelSize: 20
                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        gameOverLayer.visible = false;
                        
                        // 先瞬间让前端回到没计算压力和动画的主页面
                        window.page = "begin";
                        
                        // 用 Qt 的多线程延后一帧来大换血后端底层指针
                        Qt.callLater(function() {
                            if (network.isConnected) {
                                network.disconnectFromServer();
                            }
                            globalRule.resetRule();
                            board.resetBoard();
                        });
                    }
                }
            }
        }
    }
}
