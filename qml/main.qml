import QtQuick 2.3
import QtQuick.Window 2.2

import "Resources"

Window {
    visible: true
    width: 384 * 2
    height: 640 * 2

    Manager{
        id: _R
        source: "definition.json"
    }

    Image{
        resource : _R.getByID("menuExit")
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
//            Qt.quit();
            console.log(JSON.stringify(_R.getByID("menuExit")));
        }
    }

    Text {
        text: qsTr("Hello World")
        anchors.centerIn: parent
    }
}
