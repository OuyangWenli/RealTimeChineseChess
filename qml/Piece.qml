// 棋子组件
import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: piece
    width: 60
    height: 60
    scale: isSelected ? 1.08 : 1.0 // 被选中时稍微放大一点，通过 scale 居中放大

    rotation: network.localColor === 1 ? 180 : 0 // 联机模式下黑方棋子旋转180度

    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    property string pieceName
    property string color
    property bool isSelected: false

    // 网络等待状态：当客户端发送走子请求后，处于等待服务器仲裁确认的临时状态
    // 在这个状态下，棋子仍然保持选中状态，但不允许再次选中或移动，直到服务器广播确认后才清理这个状态
    // 这个设计是为了避免在网络延迟较高时，玩家会看到棋子先落子再移动的错觉（因为本地动画和位置已经改变了，但服务器还没确认）
    property bool awaitingServer: false
    property var pendingMove: null

    property color zeroAPColor:'#dab318'
    property color oneAPColor:'#026ec0'

    property int logicX: 0
    property int logicY: 0

    property int initialLogicX: logicX
    property int initialLogicY: logicY

    Component.onCompleted: {
        initialLogicX = logicX;
        initialLogicY = logicY;
    }

    // 棋盘图片引用，为了避免名字冲突，命名为 parentBoard
    // 这个属性会在创建 Piece 时由外部传入，即 Board.qml 中的 parentBoard: boardContainer.chessBoardImage
    // chessBoardImage是定义在Board.qml中的chessBoard的引用，专门用来暴露给外部
    property var parentBoard: null

    property real scaleX: parentBoard ? (parentBoard.width / 2732.0) : 1
    property real scaleY: parentBoard ? (parentBoard.height / 1534.0) : 1

    property var backendPiece: board.getPieceQml(logicX, logicY)

    property real cdPercent: backendPiece ? (backendPiece.m_actionPoint === backendPiece.m_maxActionPoint ? 100 : 0) : 100

    Connections {
        target: board
        function onBoardReset() {
            cdTimer.stop();
            piece.logicX = piece.initialLogicX;
            piece.logicY = piece.initialLogicY;
            // 重新获取被C++的resetBoard重建的新指针
            piece.backendPiece = Qt.binding(function() { return board.getPieceQml(piece.logicX, piece.logicY); });
            piece.cdPercent = piece.backendPiece ? (piece.backendPiece.m_actionPoint === piece.backendPiece.m_maxActionPoint ? 100 : 0) : 100;
            piece.isSelected = false; // 取消选中状态
            piece.visible = true; // 恢复显示
            piece.enabled = true; // 恢复交互
        }
    }

    Connections {
        target: backendPiece
        function onAliveChanged() {
            if (backendPiece && !backendPiece.m_alive) {
                piece.visible = false;
                piece.enabled = false;
                piece.logicX = -1;
                piece.logicY = -1;
            }
        }
        property int localActionPoint: 2
        function onActionPointChanged() {
            if (!backendPiece) return;
            var isRecovery = backendPiece.m_actionPoint > localActionPoint;
            localActionPoint = backendPiece.m_actionPoint;
            
            if (backendPiece.m_actionPoint === backendPiece.m_maxActionPoint) {
                cdTimer.stop();
                piece.cdPercent = 100.0;
            } else if (backendPiece.m_actionPoint < backendPiece.m_maxActionPoint && !cdTimer.running) {
                // 第一次被消耗（从满行动力变成不满了），说明有空缺需要开始充能
                piece.cdPercent = 0.0;
                cdTimer.lastTime = Date.now();
                cdTimer.start();
            } else if (backendPiece.m_actionPoint < backendPiece.m_maxActionPoint && cdTimer.running) {
                // 如果行动力改变时，并且圈正在转
                if (isRecovery) {
                    // 说明是后台到点涨了1层，清空圆圈重新进入下一层循环充能
                    piece.cdPercent = 0.0;
                    cdTimer.lastTime = Date.now();
                }
            }
        }
    }

    function startCD(bp) {
        var p = bp || backendPiece;
        if (p) {
            p.m_actionPoint = p.m_actionPoint - 1;
        }
    }

    Timer {
        id: cdTimer
        interval: 16 // 60帧 
        repeat: true
        running: false
        property var lastTime: 0
        onTriggered: {
            var now = Date.now();
            var dt = now - lastTime;
            lastTime = now;

            // 动态利用后端的 m_actionPointRecoveryTime 属性计算步长
            var totalCD = backendPiece ? backendPiece.m_actionPointRecoveryTime : 3000;
            var step = (dt / totalCD) * 100.0;

            // 这里仅仅是纯 UI 表现上的累加（最高100%），不再越权修改真正的数据
            cdPercent = Math.min(100.0, cdPercent + step);
        }
    }

    x: (parentBoard ? parentBoard.x : 0) + (813 + logicX * 138) * scaleX - width / 2
    property real base_y: (parentBoard ? parentBoard.y : 0) + (195 + logicY * 125) * scaleY - height / 2
    y: base_y + (isSelected ? (color === "red" ? -10 : 10) : 0)

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit  // 保持纵横比缩放
        source: "qrc:/images/" + pieceName + ".png" // 棋子图片资源路径
    }

    Rectangle {
        id: cdBack
        anchors.centerIn: parent
        width: parent.width + 2
        height: width
        radius: width / 2
        color: "transparent" // 透明背景，只有边框有颜色
        border.width: 5
        border.color: "white"
        visible: false // 隐藏，让ConicalGradient使用它
    }

    property color progressColor: {
        if (!backendPiece) return zeroAPColor;
        if (backendPiece.m_actionPoint === 0) return zeroAPColor;
        if (backendPiece.m_actionPoint === 1) return oneAPColor;
        return "transparent";
    }

    ConicalGradient {
        anchors.fill: cdBack
        source: cdBack
        enabled: backendPiece ? backendPiece.m_actionPoint < backendPiece.m_maxActionPoint : cdPercent < 100
        visible: enabled
        gradient: Gradient {
            GradientStop { position: 0.0; color: "white" }
            GradientStop { position: cdPercent / 100.0; color: piece.progressColor }
            GradientStop { position: (cdPercent / 100.0) + 0.001; color: "white" }
            GradientStop { position: 1.0; color: "white" } // 剩余部分保持白色
        }
    }

    // 当 x 和 y 属性变化时，应用平滑动画以实现对角线移动
    Behavior on x {
        NumberAnimation {
            duration: 150
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 150
            easing.type: Easing.InOutQuad // 平滑动画效果
        }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            // 获取承载选中状态的根 Board 对象
            // parentBoard 是 Image，它的父组件就是 Board.qml 中定义的 boardRoot
            var mainBoard = parentBoard ? parentBoard.parent : null
            if (!mainBoard) return;

            var currSelected = mainBoard.selectedPiece

            if (currSelected === null) {// 当前没选中，举起自己
                if (backendPiece && backendPiece.m_actionPoint < 1) return // 行动力不够不能举起

                if (network.isConnected) {
                    var isRed = (piece.color === "red");
                    var isLocalRed = (network.localColor === 0);
                    if (isRed !== isLocalRed) return; // 联机模式下只能举起自己的棋子
                }

                isSelected = true
                mainBoard.selectedPiece = piece
            } else if (currSelected === piece) { // 再次点击自己，放下
                isSelected = false
                mainBoard.selectedPiece = null
            } else if (currSelected.color === piece.color) { // 点击另一个同色的，放下旧的，举起新的
                currSelected.isSelected = false
                isSelected = true
                mainBoard.selectedPiece = piece
            } else {// 当前举起着一个己方棋子，并点击了敌方棋子，说明要吃子
                if (board.canMove(currSelected.logicX, currSelected.logicY, piece.logicX, piece.logicY)) {
                    var isGeneral = (currSelected.pieceName === "Red_G" || currSelected.pieceName === "Black_G");
                    var isRed = (currSelected.color === "red");
                    var points = isRed ? globalRule.point_red : globalRule.point_black;

                    if (!isGeneral && points < 1) {
                        currSelected.isSelected = false;
                        mainBoard.selectedPiece = null;
                        return;
                    }

                    // 记录目标坐标，因为 movePiece 会触发死亡信号导致目标子坐标马上被修改为 -1
                    var toX = piece.logicX;
                    var toY = piece.logicY;

                    if (network.isConnected) {
                        // 发送到服务器后进入“等待确认”状态：不立即在本地执行移动动画/复原，等待服务器广播后统一执行
                        network.sendMove(currSelected.logicX, currSelected.logicY, toX, toY);

                        // 标记等待（在收到服务器广播前不要复原选中与位置）
                        currSelected.pendingMove = { toX: toX, toY: toY };
                        currSelected.awaitingServer = true;

                        // 将选中状态保留（不要立刻放下），由服务端确认后统一清理
                        return;
                    }

                    // 离线或未联网状态：直接执行本地移动（原有逻辑）
                    // 调用后端 movePiece
                    board.movePiece(currSelected.logicX, currSelected.logicY, toX, toY);

                    // 被选中的棋子挪过来
                    currSelected.logicX = toX
                    currSelected.logicY = toY
                    currSelected.isSelected = false
                    mainBoard.selectedPiece = null

                    // 死亡棋子的隐藏交由 onAliveChanged 信号处理，但也可以在此处作为双重保险
                    piece.visible = false
                    piece.enabled = false
                    piece.logicX = -1
                    piece.logicY = -1

                    currSelected.startCD(board.getPieceQml(currSelected.logicX, currSelected.logicY)) // 启动自身CD
                }
                else {
                    currSelected.isSelected = false
                    mainBoard.selectedPiece = null
                }
            }
        }
    }
}