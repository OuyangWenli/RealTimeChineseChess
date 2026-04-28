// 动画效果
import QtQuick

Item {
    id: dynamicRoot
    width: 60
    height: 400

    property bool isRed: true
    
    property int currentPoints: isRed ? globalRule.point_red : globalRule.point_black
    property int maxPoints: isRed ? globalRule.MaxPoint_red : globalRule.MaxPoint_black
    property int recoveryTime: isRed ? globalRule.pointRecoveryTime_red : globalRule.pointRecoveryTime_black

    // 真正的动画进度属性 (0 到 100)
    property real barPercent: 0.0
    // 记录上一次的点数以便判定变化类型（恢复 / 消耗 / 从满变为未满）
    property int lastPoints: currentPoints

    // 整体纵向进度条区域
    Rectangle {
        id: back
        width: 30
        height: 300
        radius: width / 2
        color: '#88605c5c' // 透明背景，只有前景条有颜色
        anchors.centerIn: parent

        Rectangle {
            id: front
            width: parent.width
            radius: parent.radius
            // 高度由 barPercent 决定
            height: (dynamicRoot.barPercent / 100.0) * parent.height
            color: dynamicRoot.isRed ? "#FF4D4D" : '#0c0c59' // 红色或蓝色前景条

            // 根据红黑方决定朝上还是朝下生长
            anchors.bottom: dynamicRoot.isRed ? parent.bottom : undefined
            anchors.top: dynamicRoot.isRed ? undefined : parent.top
        }

        // 充满整个进度条的底层计时动画，控制 barPercent 从 0 到 100 循环
        NumberAnimation {
            id: progressAnim
            target: dynamicRoot
            property: "barPercent"
            from: 0.0
            to: 100.0
            duration: dynamicRoot.recoveryTime
            running: dynamicRoot.visible && (dynamicRoot.currentPoints < dynamicRoot.maxPoints)
            loops: Animation.Infinite
        }
    }

    onCurrentPointsChanged: {
        if (currentPoints < maxPoints) {
            if (lastPoints === maxPoints || currentPoints > lastPoints) {
                // 从满点消费或者恢复到更高点数，重置进度条并从 0 开始
                barPercent = 0.0;
                progressAnim.restart();
            } else {
                // 消耗指挥点时，保持当前动画进度，不重置
                // 如果动画未在运行（例如刚从满点切换过），确保它在需要时运行
                if (!progressAnim.running) progressAnim.start();
            }
        } else {
            // 达到满点，停止动画并显示为满
            progressAnim.stop();
            barPercent = 100.0;
        }

        // 更新 lastPoints
        lastPoints = currentPoints;
    }

    // 数字显示区域
    Item {
        id: displayItem
        width: parent.width
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: dynamicRoot.isRed ? back.top : undefined
        anchors.top: dynamicRoot.isRed ? undefined : back.bottom
        anchors.bottomMargin: dynamicRoot.isRed ? 10 : 0
        anchors.topMargin: dynamicRoot.isRed ? 0 : 10

        // 数字显示组件（当前 / 上限）
        Text {
            anchors.centerIn: parent
            font.pointSize: 18
            font.bold: true
            text: dynamicRoot.currentPoints.toString() + " / " + dynamicRoot.maxPoints
            color: dynamicRoot.isRed ? "#CC0000" : '#111165' // 红色或蓝色文本
            rotation: network.localColor === 1 ? 180 : 0
        }
    }
}