import QtQuick 2.0

Image{
    id: image
    property variant resource: null
//    property alias forceWidth: resourceData.forcedWidth
//    property alias forceHeight: resourceData.forcedHeight

    width: _R.scale(resource.width.value)
    height: _R.scale(resource.height.value)

    source: resource.fileMap[_R.scaleSuffix]

    asynchronous: false
    cache: true

    fillMode: Image.Stretch
    smooth: true

    sourceSize.width: resource.width.value
    sourceSize.height: resource.height.value
}
