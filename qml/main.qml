import QtQuick 2.3
import QtQuick.Window 2.2

import "Resources"

Window {
    id: app
    visible: true
    width: 320
    height: 480

    Manager{
        id: _R
        appWindow: parent
        source: "definition.json"
    }

    Image{
        resource : _R.getByID("exit")
        anchors.centerIn: parent
    }

    Text {
        text: qsTr("Hello World")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenterOffset: 150
        anchors.verticalCenter: parent.verticalCenter
    }
}
