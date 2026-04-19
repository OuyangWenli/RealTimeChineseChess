// 按钮组件
import QtQuick

Item {
    id: buttonNode
    width: 90
    height: 90

    property string imageName: ""
    property int logicX: 0
    property int logicY: 0
    property bool isPressed: false

    property var parentBoard: null
    property real scaleX: parentBoard ? (parentBoard.width / 2732.0) : 1
    property real scaleY: parentBoard ? (parentBoard.height / 1534.0) : 1

    x: (parentBoard ? parentBoard.x : 0) + (813 + logicX * 138) * scaleX - width / 2
    property real base_y: (parentBoard ? parentBoard.y : 0) + (189 + logicY * 125) * scaleY - height / 2
    y: base_y + (isPressed ? 5 : 0)

    signal clicked()

    Behavior on y {
        NumberAnimation {
            id: pressAnim
            duration: 40
            easing.type: Easing.InOutQuad
        }
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/" + imageName + ".png"
    }

    Timer {
        id: delayTimer
        interval: 50 // 延迟50毫秒跳转，给足按钮下沉和播放特效的时间
        repeat: false
        onTriggered: {
            isPressed = false
            buttonNode.clicked()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            isPressed = true
            delayTimer.start()
        }
    }
}