/****************************************************************************
**
** QML Resources manager
** Source: https://github.com/it-s/resqt
** (c) 2014 - Eugene Trounev (it-s)
** License: Apache License. See the LICENSE file for details
**
****************************************************************************/

import QtQuick 2.2
import QtQuick.Window 2.0

import "js/undersore.js" as U_

Item {
    id: manager

    visible: false // We don't want this element to be visible as it's just a holder

    property variant appWindow: null    //This has to be set to the main application window
                                        //We need it to track the window size changes
    property string source: ""          //Resources definition file file
    property string resourcesDir: "/resources/" //Base resources directory. All our resources go here

    property int screenWidth: appWindow.width   //Total width of our app window (Normally on mobile app fills the screen)
    property int screenHeight: appWindow.height //Total height of our app window (Normally on mobile app fills the screen)
    property int intendedScreenWidth: 0         //The width our original assets are targeted for
    property int intendedScreenHeight: 0        //The height our original assets are targeted for

    property real scaleRatio: 1                 //Scale relation between our assets resolution and app resolution
    property string scaleSuffix: "1"            //The scale suffix. We use this to choose the correct resolution for our assets
    property variant scalesSupported: null      //List of supported scales as defined by the resources definition file [scalesSupported]

    property bool ready: false          //Tells us if the manager is ready and the definition has been loaded.

//    Private functions -->
    property variant _definition: null  //Internal "hidden*" property that holds the loaded resource data
    property variant _cache: null       //Internal "hidden*" property that holds resourceID-to-resourceData mapping for faster retrivals

    //Internal "hidden*" functon to check if the manager is ready
    //All it does is test the definition and cache to be null
    function _checkIfReady(){
        ready = (!U_.isNull(_definition) &&
                 !U_.isNull(_cache));
        return ready;
    }

    //Internal "hidden*" functon to compute and set out scaleRatio, and scaleSuffix
    //relative to what application is at right now, versus what our resources support
    function _computeScreenScaleRatio(){
        var d, appd, suffixValue, suffixScale;
        //First lets check if all our required values are there:
        if (    !screenWidth ||
                !screenHeight||
                !intendedScreenWidth||
                !intendedScreenHeight) return false;
        //Compute the diagonal length of the intended resolution (SHOULD)
        d = Math.sqrt(intendedScreenWidth*intendedScreenWidth + intendedScreenHeight*intendedScreenHeight);
        //Compute the diagonal length of the current app window (IS)
        appd = Math.sqrt(screenWidth*screenWidth + screenHeight*screenHeight);
        //Calculate the ration between what IS and what SHOULD be
        scaleRatio =  appd/d;
        //Lets reduce our value to an acceptable numeric range ...
        suffixValue = (scaleRatio < 1)?
                    (Math.round(scaleRatio) === 0 ? 0.5 : Math.round(scaleRatio))
                   : Math.floor(scaleRatio);
        //And find the name of the resource group that corresponds to it
        //  || OR assign the max resource group possible if the scale is out of range
        suffixScale = U_.find(scalesSupported, function(scale, index){
            return scale.value === suffixValue;
        }) || U_.max(scalesSupported, function(scale){ return scale.value; });
        //Safely assign the scale name to the Manager's scaleSuffix public variable
        scaleSuffix = suffixScale.name || "";
        //Notify our app that resolution has changed
        resolutionChanged(scaleRatio);
        return true;
    }

    //Internal "hidden*" functon to update the resource cache
    // when we load/reload the definition file from storage
    function _updateResourceCache(){
        var images = _definition["images"] || null, c = {};
        //Check if the deefinition has images array list
        if ( U_.isUndefined(images)  || U_.isNull(images) || images.length === 0) return false;
        //Iterate the array and pick out all the resource names (IDs) from the list for later refference
        U_.each(images, function(image, index){
            c[image.name] = index;
        });
        _cache = c;
        return true;
    }

    //Internal "hidden*" functon called when our resource definition loads from storage
    function _prepareResources(){
        ready = false;
        //Check if definition has been loaded and it's the object we need
        if (!_definition || !_definition.intendedResolution) return;
        //Update the Manager public properties:
        intendedScreenWidth     = _definition.intendedResolution.width;
        intendedScreenHeight    = _definition.intendedResolution.height;
        scalesSupported         = _definition.scalesSupported;
        //Call cache update
        if (!_updateResourceCache()) return;
        _checkIfReady();
    }

    //Internal "hidden*" functon that parse the definition file
    // and generates additional data we will need later
    function _parseDefinition(d){
        var definition = JSON.parse(d);
        var baseDir = resourcesDir + definition.imagesBaseDir + "/";
        //Compose the filly qualified resource file path
        function fullFilePath(baseDir, fileName, suffix){
            return baseDir + fileName.replace(/(.*)\.(.*?)$/, "$1" + suffix + ".$2");
        }
        //Compute the intervals we need to decide when to show which resolution
        // out of the list of available
        function setIntervals(o){
            var m = 0,
                c = U_.map( U_.sortBy(o, function(v){return v.value;}),
                    function(v, i){
                        v['min'] = m;
                        v['max'] = ( i === o.length - 1)? 99 : m = v.value;
                        return v;
                    });
            return c;
        }
        //Find the best fittting scale for each defined resolution category
        function findBestScaleFor(scale, scalesAvailabe){
            return U_.find(scalesAvailabe ,function(o){
                return o.min < scale.value && scale.value <= o.max;
            });
        }
        //First we make sure our list of supported resolitions is sorted by value min-to-max
        definition.scalesSupported = U_.sortBy(definition.scalesSupported, function(o){return o.value;});
        //Then we iterate each image resource on the list to determine what fits the best
        // out of what it supports
        definition.images = U_.map(definition.images, function(image){
            var fileMap = {},
                //Use setIntervals function to create min/max interval map for each target resolution supported
                scalesAvailabe = setIntervals(U_.filter(definition.scalesSupported, function(scale, index){
                    return U_.contains(image.scalesAvailabe, scale.name);
                }));
            //Iterate each upported resolution and compare which interwal it fits the best
            U_.each(definition.scalesSupported, function(scale, index){
                fileMap[scale.name] = fullFilePath(baseDir, image.file,
                                            findBestScaleFor(scale, scalesAvailabe).suffix);
            });
            //finally add everything we have just computed to the [image] object for later use
            return U_.extend(image, {
                                 "fileMap": fileMap,
                                 "baseDir": baseDir
                             });
        });
        return definition;
    }

    //Internal "hidden*" functon that attempts to load the definition file from storage
    function _loadDefinition(){
        var request = new XMLHttpRequest()
        console.log("Loading resource definition...")
        ready = false;
        if (source === "") return false;
        request.open('GET', (resourcesDir + source));
        request.onreadystatechange = function(event) {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (!request.responseText){
                    console.log("Resource definition file not found or is empty.");
                    return false;
                }
                console.log ("success");
                manager._definition = _parseDefinition(request.responseText);
                _prepareResources();
                return true;
            }
        }
        request.send()
    }

//    Signal Listeners -->

    //Track app width cahnges (we don't really need this on mobile, but we do on desktop
    onScreenWidthChanged:   _computeScreenScaleRatio()
    //Track app height cahnges (we don't really need this on mobile, but we do on desktop
    onScreenHeightChanged:  _computeScreenScaleRatio()
    //Track the source file changes and load it from the storage
    onSourceChanged: _loadDefinition()

//    Signals Listeners -->
    //Signal we emit when resolution has changed and all the relevant values re-computed
    signal resolutionChanged

//    Public Functions -->

    //Public function that calculates the value (width, height, top,...) based on current app screen scale
    // relative to what app was intended for, rounded to the next whole pixel
    function scale(n){
        return Math.ceil(n * scaleRatio);
    }

    //Public function that returns our resource object by ID using the resource cache
    // to save time/resources
    function getByID(resource){
        if (!ready) return null;
        if ( !hasID(resource) ){
            console.log("Could not find resource with ID: " + resource);
            return null;
        }

        return _definition.images[_cache[resource]]
    }

    //Public function that checks if we have the resource we are asking for
    function hasID(resource){
        if (!ready) return undefined;
        return U_.has( _cache, resource );
    }
}
