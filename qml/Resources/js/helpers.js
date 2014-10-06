.pragma library

.import "undersore.js" as U_

function getResourceProperty( o, name ){
    var res;
    if(!U_.isObject(o)) return o;
    if(U_.isObject(o["resource"])&&U_.has(o["resource"], name)) res = o["resource"];
    else res = o;
    return res[name];
}

function getValue( o, name ){
    name = name || "value";
    if (U_.isObject(o)&&o[name]) return o[name];
        else if (U_.isObject(o)) return null;
        else return o;
}

function clamp( value, min, max ) {
    min = min || value;
    max = max || value;
    return Math.max( Math.min( value, max ), min);
}

function ratio( a, b ) {
    return a / b;
}
