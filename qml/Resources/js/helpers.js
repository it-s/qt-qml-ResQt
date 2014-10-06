.pragma library

function getValue(o, name){
    name = name || "value";
    if (U_.isObject(o)&&o[name]) return o[name];
        else return o;
}

function clamp(value, max, min) {
    return Math.max(
                Math.min( value, max ),
                min);
}
