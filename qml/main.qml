import QtQuick 
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia

Window {
    id: window
    width: 1400
    height: 800
    visible: true
    title: qsTr("RealTimeChess")

    property string page: "begin"

    MediaPlayer {
        id: beginMusicPlayer
        audioOutput: AudioOutput {}
        source: "qrc:/music/beginMusic.mp3"
        loops: MediaPlayer.Infinite
    }

    MediaPlayer {
        id: fightingMusicPlayer
        audioOutput: AudioOutput {}
        source: "qrc:/music/fightingMusic.mp3"
        loops: MediaPlayer.Infinite
    }

    onPageChanged: {
        if (page === "begin") {
            fightingMusicPlayer.stop();
            beginMusicPlayer.play();
        }
        else if (page === "fighting") {
            beginMusicPlayer.stop();
            fightingMusicPlayer.play();
        }
    }

    Component.onCompleted: {
        beginMusicPlayer.play();
    }

    Begin{
        anchors.fill: parent
        visible: window.page === "begin"
        enabled: window.page === "begin"
    }

    Fighting{
        anchors.fill: parent
        visible: window.page === "fighting"
        enabled: window.page === "fighting"
    }
}
