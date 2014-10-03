import QtQuick 2.2
import QtQuick.Window 2.0

import "js/undersore.js" as U_

Item {
    id: manager
    anchors.fill: parent

    property string source: ""
    property string resourcesDir: "/resources/"

    property int screenWidth: manager.width
    property int screenHeight: manager.height
    property int intendedScreenWidth: 0
    property int intendedScreenHeight: 0

    property real scaleRatio: 1
    property string scaleSuffix: ""
    property variant scalesSupported: null

    property bool ready: false


//    Private functions -->
    property variant _definition: null
    property variant _cache: null

    function _checkIfReady(){
        ready = (screenWidth &&
                 screenHeight &&
                 intendedScreenWidth &&
                 intendedScreenHeight &&
                 _definition != null &&
                 _cache != null);
        return ready;
    }

    function _computeResolutionSuffix(){
        console.log(scaleRatio)
        scaleSuffix = String((scaleRatio < 1)?
                                 (Math.round(scaleRatio) === 0 ? 0.5 : Math.round(scaleRatio))
                               : Math.floor(scaleRatio));
        _checkIfReady();
    }

    function _computeScreenScaleRatio(){
        if (    !screenWidth ||
                !screenHeight||
                !intendedScreenWidth||
                !intendedScreenHeight) return 1;
        var d = Math.sqrt(intendedScreenWidth*intendedScreenWidth + intendedScreenHeight*intendedScreenHeight); //diagonaly(w,h);
        var appd = Math.sqrt(screenWidth*screenWidth + screenHeight*screenHeight);
        scaleRatio =  appd/d;
        _checkIfReady();
    }

    function _updateResourceCache(){
        var images = _definition["images"];
        if ( U_.isUndefined(images) || U_.isNull(images) || images.length === 0) return;
        var c = {};
        U_.each(images, function(image, index){
            c[image.name] = index;
        });
        _cache = c;
        _checkIfReady();
    }

    function _parseDefinition(d){
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
            return U_.find(setIntervals(scalesAvailabe),function(o){
                return o.min < scale.value && scale.value <= o.max;
            });
        }
        definition.scalesSupported = U_.sortBy(definition.scalesSupported, function(o){return o.value;});
        definition.images = U_.map(definition.images, function(image){
            var fileMap = {};
            var scales = setIntervals(U_.pick(definition.scalesSupported, image.scalesAvailabe));
            U_.each(definition.scalesSupported, function(scale, index){
                fileMap[scale.name] = fullFilePath(baseDir, image.file,
                                            findBestScaleFor(scale, scales).suffix);
            });
            return U_.extend(image, {
                                 "fileMap": fileMap,
                                 "baseDir": baseDir
                             });
        });
        return definition;
    }

    function _loadDefinition(){
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
                manager._definition = _parseDefinition(request.responseText);
            }
        }
        request.send()
    }

    Component.onCompleted: _loadDefinition()

//    Signal Listeners -->

    onScreenWidthChanged:   _computeScreenScaleRatio()
    onScreenHeightChanged:  _computeScreenScaleRatio()

    on_DefinitionChanged: {
        ready = false;
        if (!_definition || !_definition.intendedResolution) return;
        intendedScreenWidth = _definition.intendedResolution.width;
        intendedScreenHeight = _definition.intendedResolution.height;
        scalesSupported = _definition.scalesSupported;
        _computeScreenScaleRatio();
        _computeResolutionSuffix();
        _updateResourceCache();
        _checkIfReady();
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

        return _definition.images[_cache[resource]]
    }

    function hasID(resource){
        if (!ready) return undefined;
        return U_.has( _cache, resource );
    }
}
