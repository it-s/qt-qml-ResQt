import QtQuick 2.0

Image{
    id: image
    property string resource: ""
    property alias forceWidth: resourceData.forcedWidth
    property alias forceHeight: resourceData.forcedHeight
    Resource {
        id: resourceData;
        name: image.resource;
    }

    width: resourceData.width
    height: resourceData.height

    source: resourceData.source

    asynchronous: false
    cache: true

    fillMode: Image.Stretch
    smooth: true

    sourceSize.width: resourceData.sourceWidth
    sourceSize.height: resourceData.sourceHeight
}
