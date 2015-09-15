import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.2

Window{
  id: root_window
  title: 'stream-harbor';
  visible: true;
  ScrollView{
    width: root_window.width
    height: 400
    id: view
    ListView {
      Component.onCompleted: { messages_view.positionViewAtEnd(); }
      onWidthChanged: { messages_view.positionViewAtEnd(); }
      onContentHeightChanged: { messages_view.positionViewAtEnd(); }
      id: messages_view
      clip: true
      focus: true
      spacing: 5
      model: messages;
      onModelChanged: {
        messages_view.positionViewAtEnd();
        console.log("hello");
        messages_view.positionViewAtEnd();
      }
      delegate:
      Row{
        Row{
          Image{
            source: modelData.avatar
          }
          Text{
            font.pixelSize: 16;
            color: "red"
            text: modelData.nick + ": "
          }
        }
        Text {
          wrapMode: Text.Wrap
          font.pixelSize: 16;
          width: messages_view.width - 30
          text: modelData.content; color: "black";
        }
      }
    }
  }
  TextInput {
    id: input;
    anchors.top: view.bottom
    anchors.topMargin: 20;
    anchors.bottom: root_window.bottom
    width: 300;
    //height: 20;
    font.pixelSize: 20;
    focus: true;
  }
  Button{
    anchors.top: view.bottom
    anchors.topMargin: 20;
    anchors.bottom: root_window.bottom
    anchors.left: input.right
    anchors.right: root_window.right
    text: "Send"
    onClicked: sendChatMessage(input.text);
  }
}
