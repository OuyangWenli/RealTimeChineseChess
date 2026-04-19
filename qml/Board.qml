// 棋盘组件
import QtQuick

Item {
    id: boardRoot
    width: parent ? parent.width : 800
    height: parent ? parent.height : 600

    Image {
        id: chessBoard
        source: "qrc:/images/chessBoard.png"
        
        // 原始像素尺寸
        sourceSize.width: 2732
        sourceSize.height: 1534

        // 动态相对于父窗口(即主窗口)居中并且保持纵横比缩放
        anchors.centerIn: parent
        
        // 当窗口变化时，确保图片按比例缩放并适应窗口大小，不超出边界
        width: Math.min(parent.width, parent.height * (2732 / 1534))
        height: Math.min(parent.height, parent.width / (2732 / 1534))
        
        fillMode: Image.PreserveAspectFit  // 保持纵横比缩放

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => {
                if (boardRoot.selectedPiece) {
                    // 判断点击的位置对应哪个逻辑坐标 logicX, logicY
                    var scaleX = width / 2732.0;
                    var scaleY = height / 1534.0;

                    var rawX = mouse.x / scaleX;
                    var rawY = mouse.y / scaleY;

                    var lx = Math.round((rawX - 813) / 138.0); // 注意要四舍五入，因为可能点得不太准
                    var ly = Math.round((rawY - 195) / 125.0);

                    if (lx >= 0 && lx <= 8 && ly >= 0 && ly <= 9) {
                        var logicX = boardRoot.selectedPiece.logicX;
                        var logicY = boardRoot.selectedPiece.logicY;

                        if (board.canMove(logicX, logicY, lx, ly)) {
                            var isGeneral = (boardRoot.selectedPiece.pieceName === "Red_G" || boardRoot.selectedPiece.pieceName === "Black_G");
                            var isRed = (boardRoot.selectedPiece.color === "red");
                            var points = isRed ? globalRule.point_red : globalRule.point_black;

                            if (!isGeneral && points < 1) {
                                boardRoot.selectedPiece.isSelected = false;
                                boardRoot.selectedPiece = null;
                                return;
                            }

                            if (!isGeneral) {
                                if (isRed) {
                                    globalRule.point_red = globalRule.point_red - 1;
                                } else {
                                    globalRule.point_black = globalRule.point_black - 1;
                                }
                            }

                            if (network.isConnected) {
                                network.sendMove(logicX, logicY, lx, ly);
                            }

                            // 调用后端 movePiece 移动
                            board.movePiece(logicX, logicY, lx, ly);

                            // 启动自身CD，直接通过C++方法拿到最新坐标上的棋子对象
                            boardRoot.selectedPiece.startCD(board.getPieceQml(lx, ly));

                            // 前端移动成功
                            boardRoot.selectedPiece.logicX = lx;
                            boardRoot.selectedPiece.logicY = ly;
                            boardRoot.selectedPiece.isSelected = false; // 放下棋子
                            boardRoot.selectedPiece = null;
                        } else {
                            // 如果不能移动，则只取消选中状态
                            boardRoot.selectedPiece.isSelected = false;
                            boardRoot.selectedPiece = null;
                        }
                    }
                }
            }
        }
    }

    property alias chessBoardImage: chessBoard // 把 image 开放出来让外部棋子可以拿到它的动态缩放后长宽
    property var selectedPiece: null

    Connections {
        target: network
        function onMoveReceived(fx, fy, tx, ty) {
            var p = null;
            for (var i = 0; i < boardRoot.children.length; ++i) {
                var child = boardRoot.children[i];
                if (child.logicX === fx && child.logicY === fy && child.pieceName !== undefined) {
                    p = child;
                    break;
                }
            }
            if (!p) return;

            var isGeneral = (p.pieceName === "Red_G" || p.pieceName === "Black_G");
            var isRed = (p.color === "red");

            if (!isGeneral) {
                if (isRed) {
                    globalRule.point_red = globalRule.point_red - 1;
                } else {
                    globalRule.point_black = globalRule.point_black - 1;
                }
            }

            board.movePiece(fx, fy, tx, ty);

            p.startCD(board.getPieceQml(tx, ty));

            p.logicX = tx;
            p.logicY = ty;
        }
    }

    Connections {
        target: board
        function onBoardReset() {
            if (boardRoot.selectedPiece) {
                boardRoot.selectedPiece.isSelected = false;
                boardRoot.selectedPiece = null;
            }
        }
    }
}