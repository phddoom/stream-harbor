import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Window 2.2

Window{
  id: root_window
  title: 'stream-harbor';
  visible: true;
  Column {
    ScrollView{
      width: root_window.width; height: root_window.height - 400;
      ListView {
        focus: true
        width: parent.width; height: parent.height;
        model: messages;
        delegate:
        Row{
          Column{
            Image{
              source: modelData.avatar
            }
            Text{
              font.pixelSize: 16;
              color: "red"
              text: modelData.nick
            }
          }
          Text {
            wrapMode: Text.Wrap
            font.pixelSize: 16;
            text: modelData.content; color: "black";
          }
        }
      }
    }
    TextInput {
      id: input;
      width: 300;
      height: 30;
      font.pixelSize: 30;
      focus: true;
    }
    Button{
      text: "Send"
      onClicked: sendChatMessage(input.text);
    }
  }
}
