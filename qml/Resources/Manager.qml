import QtQuick 2.2
import QtQuick.Window 2.0

Item {
    id: manager

    property string definition: ""
    property string resourcesDir: "/resources/"

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height
    property int resourcesScreenWidth: 0
    property int resourcesScreenHeight: 0

    property string suffix: ""
    property double scaleRatio: 1

    property bool ready: false

    property variant dictionary: null
    property variant dictionaryCache: null

//    Private functions -->

    function ___checkIfReady(){
        ready = (screenWidth &&
                 screenHeight &&
                 resourcesScreenWidth &&
                 resourcesScreenHeight &&
                 dictionary != null &&
                 dictionaryCache != null);
        return ready;
    }

    function ___computeResolutionSuffix(){
        if (scaleRatio <= 0.5) suffix = "0.5x";
        else if (scaleRatio >= 2 && scaleRatio < 3) suffix = "2x";
        else if (scaleRatio >= 3 && scaleRatio < 4) suffix = "3x";
        else if (scaleRatio >= 4) suffix = "4x";
        else suffix = "";
        ___checkIfReady();
    }

    function ___computeScreenScaleRatio(){
        if (    !screenWidth ||
                !screenHeight||
                !resourcesScreenWidth||
                !resourcesScreenHeight) return 1;
        var d = Math.sqrt(resourcesScreenWidth*resourcesScreenWidth + resourcesScreenHeight*resourcesScreenHeight); //diagonaly(w,h);
        var appd = Math.sqrt(screenWidth*screenWidth + screenHeight*screenHeight);
        scaleRatio =  appd/d;
        ___checkIfReady();
    }

    function ___updateResourceCache(){
        var images = dictionary["images"];
        if (images === undefined || images === null || images.length === 0) return;
        var c = {};
        for (var key in images){
            var image = images[key];
            c[image.name] = key;
        }
        dictionaryCache = c;
        ___checkIfReady();
    }

    function ___loadDefinition(){
        console.log("Loading resource definition...")
        if (definition === "") return;
        var request = new XMLHttpRequest()
        request.open('GET', (resourcesDir + definition));
        request.onreadystatechange = function(event) {
            if (request.readyState == XMLHttpRequest.DONE) {
                if (!request.responseText){
                    console.log("Resource definition file not found or is empty.");
                    return;
                }
                console.log ("success");
                manager.dictionary = JSON.parse(request.responseText);
            }
        }
        request.send()
    }

    Component.onCompleted: ___loadDefinition()

//    Signal Listeners -->

    onScreenWidthChanged:   ___computeScreenScaleRatio()
    onScreenHeightChanged:  ___computeScreenScaleRatio()
    onScaleRatioChanged:    ___computeResolutionSuffix()

    onDictionaryChanged: {
        if (!dictionary || !dictionary.intendedWidth) return;
        resourcesScreenWidth = dictionary.intendedWidth;
        resourcesScreenHeight = dictionary.intendedHeight;
        ___computeScreenScaleRatio();
        ___updateResourceCache();
        ___checkIfReady();
    }

//    Public Functions -->

    function scale(n){
        return Math.ceil(n * scaleRatio);
    }

    function get(resource){
        if (!ready) return null;
        var images = dictionary.images;
        var res = images[dictionaryCache[resource]];
        var baseDir = resourcesDir + dictionary.baseDir + "/";
        res["fileFullPath"] = baseDir + res["path"].replace(/(.*)\.(.*?)$/, "$1" + (
                                               res[suffix]?suffix:""
                                               ) + ".$2");
        return res;
    }

    function has(resource){
        if (!ready) return undefined;
        for(var key in dictionaryCache){
            if ( key === resource ) return true;
        }
        return false;
    }


}
