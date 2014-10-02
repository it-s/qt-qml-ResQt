import QtQuick 2.0

Item {
    property string name: ""

    property int sourceWidth: 0
    property int sourceHeight: 0
    property int forcedWidth: 0
    property int forcedHeight: 0
    property string source: ""

    property variant definition: _R.get(name)

    onDefinitionChanged: {
        source = definition.fileFullPath;
        sourceWidth = definition.width;
        sourceHeight = definition.height;
    }
}
