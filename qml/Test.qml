import QtQuick 2.0
import QtQuick.Layouts 1.1

import "Resources"

Rectangle {
    id: rectangle2
    width: 320
    height: 480
    color: "#dddddd"

    ColumnLayout {
        id: columnLayout1
        anchors.fill: parent

        Rectangle {
            id: rectangle1
            Layout.fillWidth: true
            Layout.preferredHeight: _R.scale(48)
            color: "#0084b6"

            RowLayout {
                id: rowLayout1
                anchors.rightMargin: _R.scale(8)
                anchors.leftMargin: _R.scale(8)
                anchors.fill: parent

                Text {
                    id: text1
                    color: "#ffffff"
                    text: qsTr("Header: Text Scaling Test")
                    font.family: "Verdana"
                    font.pixelSize: _R.scale(16)
                }
            }
        }

        Item {
            id: item1
            Layout.fillWidth: true
            Layout.fillHeight: true
            Image{
                resource : _R.getByID("image")
                anchors.centerIn: parent
            }
        }
        Row {
            Layout.fillWidth: true
            Layout.preferredHeight: _R.scale(60)
            Repeater{
                model: 4
                Image {
                   resource : _R.getByID("image")
                   forceWidth: app.width / 4
                }
            }
        }
        Rectangle {
            id: rectangle3
            color: "#ffffff"
            Layout.fillWidth: true
            Layout.preferredHeight: _R.scale(48)

            RowLayout {
                id: rowLayout2
                anchors.rightMargin: _R.scale(8)
                anchors.leftMargin: _R.scale(8)
                anchors.fill: parent

                Text {
                    id: text2
                    text: qsTr("Footer")
                    font.family: "Verdana"
                    font.pixelSize: _R.scale(16)
                }
            }
        }
    }
}
