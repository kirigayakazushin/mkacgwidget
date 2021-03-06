import QtQuick 2.0
import QtQuick.Controls 1.4
import QtMultimedia 5.4

import "get_json.js" as Get_json

Item{
    signal next()
    signal voice_start()
    signal voice_end()
    signal hitokoto()
    width: 228
    height: 202
    Audio{
        objectName: "player"
        id:player_player
        volume: 1.0
        function do_play_stats_changed()
          {
            if( player_player.playbackState === Audio.StoppedState){
                    next()
            }
          }
          onPlaybackStateChanged: {
            do_play_stats_changed();
          }
          onErrorChanged: {
            console.log("audio error :" + player_player.errorString);
     }
    }
    Rectangle {
        x: 124
        width: 100
        height: 100
        anchors.fill: parent
        color:Qt.rgba(0,0,0,0.0)
        anchors.rightMargin: 175
        anchors.bottomMargin: 280
        anchors.leftMargin: 125
        anchors.topMargin: 100
        Image{
            id:mainImage
            width: 100
            height: 100
            visible: true
            fillMode: Image.PreserveAspectFit
            source: "../Images/Anime/asuka.png"

            MouseArea {
                id: dragRegion
                anchors.fill: parent
                property point clickPos: "0,0"
                x: 0
                y: 0
                width: 100
                height: 100
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                onPressed: {
                    clickPos  = Qt.point(mouse.x,mouse.y)
                }
                onPositionChanged: {
                    //鼠标偏移量
                    var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                    //如果mainwindow继承自QWidget,用setPos
                    mainwindow.setX(mainwindow.x+delta.x)
                    mainwindow.setY(mainwindow.y+delta.y)

                }
                acceptedButtons: Qt.LeftButton | Qt.RightButton // 激活右键（别落下这个）

                onClicked: {
                    if (mouse.button == Qt.RightButton) { // 右键菜单
                        //
                        contentMenu.popup()
                    }
                }
        }

        }
        Menu { // 右键菜单
            //title: "Edit"
            id: contentMenu

            MenuItem {
                text: "每日一句"
                onTriggered: {
                    show_window.visible=true;

//                    get_hitokoto();
                    hitokoto();
                }
            }
            MenuItem{
                text:"voice command"
                onTriggered: {
                    set_end.stop()
                    voice_start()
                    set_end.start()
                }
            }

            Menu {
                title: "换肤"

                MenuItem {
                    text: "默认皮肤"
                    onTriggered:{mainImage.source="Images/back1.png"}
                }
                MenuItem{
                    text: "第二皮肤"
                    onTriggered: {mainImage.source="Images/back2.png"}
                }
            }
            MenuItem {
                id:redio_on
                text: "开启电台"
                onTriggered: {next()}
            }
            MenuItem {
                id:redio_off
                text: "关闭电台"
                visible: false
                onTriggered: {play_stop()}
            }

            MenuSeparator { }
            MenuItem {
                text: "退出"
                onTriggered: { Qt.quit();}

            }
        }


//Anime
        AnimatedImage {
            id: animation;
            source: "../Images/Anime/asuka_高兴.gif"
            onCurrentFrameChanged: {
                if(animation.currentFrame==animation.frameCount){
                    animation.playing=false;
                }
            }
            Component.onCompleted: {
//                animation.visible=false;
//                animation.playing=false;
            }
        }
        Rectangle {
            id: show_window
            x: -112
            y: -88
            width: 132
            height: 82
            color: "#47eeee"
            border.color: "#fb7b7b"

            Text {
                id: show_window_text
                x: 4
                y: 4
                width: 124
                height: 74
                wrapMode: Text.Wrap
                text: "我好想你呀～"
                font.pixelSize: 12
            }
        }
        Component.onCompleted: {
                get_hitokoto()
        }
        Timer {
            id:timer
            interval: 5000; running: true; repeat: false
            onTriggered: show_window.visible=false;
        }
        Timer {
            id:timer_anime
            interval: 1000;running: true;repeat: false
            onTriggered: {
                animation.visible=false;
                mainImage.visible=true;
            }
        }
    }

    function get_hitokoto(str){
        timer.stop()
//        Get_json.get("http://api.hitokoto.us/rand?charset=utf-8&encode=json",
//                     function(result,json){
//                           show_window_text.text=json.hitokoto;
//                     })
        show_window_text.text=str
        timer.start()
    }
    function loaded_play(str_num){
        redio_off.visible=true
        redio_on.text="下一曲"
        player_player.pause()
        player_player.source=str_num
        player_player.play()
    }
    function play_stop(){
        redio_off.visible=false
        redio_on.text="开启电台"
        player_player.pause()
    }
    function show_text(str_num){
        timer.stop()
        timer_anime.stop()
        console.log(str_num)
        if(str_num=="识别错误"){
            show_window_text.text="识别错误";
            timer.start()
        }
        else{
        Get_json.post("http://www.tuling123.com/openapi/api",
                      "key=7319f41ea831612d94fb05c9de2cdaa3&info="+str_num,
                      function(result,json){
                          show_window.visible=true;
                          show_window_text.text=json.text;
//                          mainImage.visible=false;
//                          animation.visible=true;
                          animation.playing=true;
                          console.log(result)
                     })
            timer.start()
            timer_anime.start()
        }
    }
}
