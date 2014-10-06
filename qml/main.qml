import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import "Resources"

Window {
    id: app
    visible: true
    width: 320
    height: 528
    title: "iPhone - 320x480"

    Manager{
        id: _R
//        appWindow: app
        appWindow: columnLayout1
        source: "definition.json"
    }

    ColumnLayout {
        id: columnLayout1
        spacing: 0
        anchors.fill: parent

        ComboBox {
            id: comboBox1
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            property variant screenSize: [{"width":320,"height":480},{"width":640,"height":960},{"width":640,"height":1136},{"width":750,"height":1334}]
            model: ListModel{
                ListElement { text: "iPhone - 320x480"}
                ListElement { text: "iPhone4 - 640x960"}
                ListElement { text: "iPhone5 - 640x1136"}
                ListElement { text: "iPhone6 - 750x1334"}
            }
            onCurrentIndexChanged: {
                app.title = currentText;
                app.width = screenSize[currentIndex].width;
                app.height = screenSize[currentIndex].height + comboBox1.height;
            }
        }
        Test{
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
