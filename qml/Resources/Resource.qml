import QtQuick 2.0

Item {
    property string name: ""

    property int sourceWidth: 0
    property int sourceHeight: 0
    property int forcedWidth: 0
    property int forcedHeight: 0
    property string source: ""

    property variant definition: _R.getByID(name)

    onDefinitionChanged: {
        if (definition===null||definition===undefined) return;
        source = definition.fileMap[_R.scaleSuffix];
        sourceWidth = definition.width.value;
        sourceHeight = definition.height.value;
        width = _R.scale(definition.width.value)
        height = _R.scale(definition.height.value)
    }

    onSourceChanged: console.log(source)
}
