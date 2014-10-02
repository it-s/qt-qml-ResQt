import QtQuick 2.2
import QtQuick.Window 2.0

import "js/undersore.js" as U_

Item {
    id: manager

    property string source: ""
    property string resourcesDir: "/resources/"

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height
    property int intendedScreenWidth: 0
    property int intendedScreenHeight: 0

    property real scaleRatio: 1
    property string scaleSuffix: ""
    property variant scalesSupported: null

    property bool ready: false


//    Private functions -->
    property variant __definition: null
    property variant __cache: null

    function ___checkIfReady(){
        ready = (screenWidth &&
                 screenHeight &&
                 intendedScreenWidth &&
                 intendedScreenHeight &&
                 __definition != null &&
                 __cache != null);
        return ready;
    }

    function ___computeResolutionSuffix(){
        console.log(scaleRatio)
        scaleSuffix = String((scaleRatio < 1)?
                                 (Math.round(scaleRatio) === 0 ? 0.5 : Math.round(scaleRatio))
                               : Math.floor(scaleRatio));
        ___checkIfReady();
    }

    function ___computeScreenScaleRatio(){
        if (    !screenWidth ||
                !screenHeight||
                !intendedScreenWidth||
                !intendedScreenHeight) return 1;
        var d = Math.sqrt(intendedScreenWidth*intendedScreenWidth + intendedScreenHeight*intendedScreenHeight); //diagonaly(w,h);
        var appd = Math.sqrt(screenWidth*screenWidth + screenHeight*screenHeight);
        scaleRatio =  appd/d;
        ___checkIfReady();
    }

    function ___updateResourceCache(){
        var images = __definition["images"];
        if ( U_.isUndefined(images) || U_.isNull(images) || images.length === 0) return;
        var c = {};
        U_.each(images, function(image, index){
            c[image.name] = index;
        });
        __cache = c;
        ___checkIfReady();
    }

    function ___parseDefinition(d){
        var definition = JSON.parse(d);
        var baseDir = resourcesDir + definition.imagesBaseDir + "/";

        function fullFilePath(baseDir, fileName, suffix){
            return baseDir + fileName.replace(/(.*)\.(.*?)$/, "$1" + suffix + ".$2");
        }
        function setIntervals(o){
            var m = 0;
            return U_.map( U_.sortBy(o, function(v){return v.value;}),
            function(v, i){
                v['min'] = m;
                v['max'] = ( i == o.length - 1)? 99 : m = v.value;
                return v;
            });
        }
        function findBestScaleFor(scale, scalesAvailabe){
            console.log(JSON.stringify(scale))
            console.log(JSON.stringify(scalesAvailabe))
            console.log(JSON.stringify(setIntervals(scalesAvailabe)))
            return U_.find(setIntervals(scalesAvailabe),function(o){
                return o.min < scale.value && scale.value >= o.max;
            });
        }
        definition.scalesSupported = U_.sortBy(definition.scalesSupported, function(o){return o.value;});
//        console.log(JSON.stringify(setIntervals(definition.scalesSupported)))
        definition.images = U_.map(definition.images, function(image){
            var fileMap = {};
            U_.each(definition.scalesSupported, function(scale, index){
                console.log(JSON.stringify(findBestScaleFor(scale, image.scalesAvailabe)))
                fileMap[scale.name] = fullFilePath(baseDir, image.file,
                                            findBestScaleFor(scale, image.scalesAvailabe).suffix);
            });
            return U_.extend(image, {
                                 "fileMap": fileMap,
                                 "baseDir": baseDir
                             });
        });
        return definition;
    }

    function ___loadDefinition(){
        console.log("Loading resource definition...")
        if (source === "") return;
        var request = new XMLHttpRequest()
        request.open('GET', (resourcesDir + source));
        request.onreadystatechange = function(event) {
            if (request.readyState == XMLHttpRequest.DONE) {
                if (!request.responseText){
                    console.log("Resource definition file not found or is empty.");
                    return;
                }
                console.log ("success");
                manager.__definition = ___parseDefinition(request.responseText);
            }
        }
        request.send()
    }

    Component.onCompleted: ___loadDefinition()

//    Signal Listeners -->

    onScreenWidthChanged:   ___computeScreenScaleRatio()
    onScreenHeightChanged:  ___computeScreenScaleRatio()
    onScaleRatioChanged:    ___computeResolutionSuffix()

    on__DefinitionChanged: {
        ready = false;
        if (!__definition || !__definition.intendedResolution) return;
        intendedScreenWidth = __definition.intendedResolution.width;
        intendedScreenHeight = __definition.intendedResolution.height;
        scalesSupported = __definition.scalesSupported;
        ___computeScreenScaleRatio();
        ___updateResourceCache();
        ___checkIfReady();
    }

//    Public Functions -->

    function scale(n){
        return Math.ceil(n * scaleRatio);
    }

    function getByID(resource){
        if (!ready) return null;
        if ( !hasID(resource) ){
            console.log("Could not find resource ID:" + resource);
            return null;
        }
//        var res = U_.clone(__definition.images[__cache[resource]]);
//        return U_.extend(res, {
//                        "baseDir": resourcesDir + __definition.imagesBaseDir + "/"
//                        });

        return __definition.images[__cache[resource]]
    }

    function hasID(resource){
        if (!ready) return undefined;
        return U_.has( __cache, resource );
    }
}
