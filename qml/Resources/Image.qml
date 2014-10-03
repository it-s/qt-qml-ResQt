import QtQuick 2.0


Image{
    id: image
    property variant resource: null
    property real forceWidth: 0
    property real forceHeight: 0

    function update(){
        if (!_R.ready || resource == undefined || resource == null) return;
        width   = _R.scale(resource.width.value)
        height  = _R.scale(resource.height.value)
        source  = resource.fileMap[_R.scaleSuffix]
        sourceSize.width = resource.width.value
        sourceSize.height = resource.height.value
    }

    onResourceChanged:  update()
    Component.onCompleted: {
        _R.resolutionChanged.connect(update)
    }

    fillMode: Image.Stretch //This has to be set to stretch
}
