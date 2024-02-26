
function init() {
    var div = document.getElementById('controlAddIn');
    div.innerHTML = "";
    PrettyJsonDiv = document.createElement("div");
    PrettyJsonDiv.id = "JsonPreview";
    PrettyJsonDiv.name = "JsonPreview";
    PrettyJsonDiv.style = "height: 100%;width: 100%;overflow: auto;";
    div.appendChild(PrettyJsonDiv);
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlReady",[]);
}

function setJsonText(jsonText) {
    var PrettyJsonDiv = document.getElementById('JsonPreview');
    let HydratedJson = JSON.parse(jsonText);
    let options = { quoteKeys: true };
    let prettyJson = prettyPrintJson.toHtml(HydratedJson, options);
    PrettyJsonDiv.innerHTML = '<pre>'+prettyJson+'</pre>';
}

function setBasicText(basicText) {
    var PrettyJsonDiv = document.getElementById('JsonPreview');
    PrettyJsonDiv.innerHTML = '<pre>'+basicText+'</pre>';
}

function resizeIFrame(newheight) {
    var frameEl = window.frameElement;
    if (frameEl) {
        frameEl.style["height"] = newheight + "px";
        frameEl.style["min-height"] = newheight + "px";
        frameEl.style["max-height"] = newheight + "px";
    } 
}




// Code and related CSS styles below here from: https://github.com/center-key/pretty-print-json
const prettyPrintJson = {
    version: '1.0.0',
    toHtml(thing, options) {
        const defaults = { indent: 3, linkUrls: true, quoteKeys: false };
        const settings = { ...defaults, ...options };
        const htmlEntities = (text) => {
            return text
                .replace(/&/g, '&amp;')
                .replace(/\\"/g, '&bsol;&quot;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;');
        };
        const spanTag = (type, display) => display ? '<span class=json-' + type + '>' + display + '</span>' : '';
        const buildValueHtml = (value) => {
            const strType = /^"/.test(value) && 'string';
            const boolType = ['true', 'false'].includes(value) && 'boolean';
            const nullType = value === 'null' && 'null';
            const type = boolType || nullType || strType || 'number';
            const urlRegex = /https?:\/\/[^\s"]+/g;
            const makeLink = (link) => '<a class=json-link href="' + link + '">' + link + '</a>';
            const display = strType && settings.linkUrls ? value.replace(urlRegex, makeLink) : value;
            return spanTag(type, display);
        };
        const replacer = (match, p1, p2, p3, p4) => {
            const part = { indent: p1, key: p2, value: p3, end: p4 };
            const findName = settings.quoteKeys ? /(.*)(): / : /"([\w$]+)": |(.*): /;
            const indentHtml = part.indent || '';
            const keyName = part.key && part.key.replace(findName, '$1$2');
            const keyHtml = part.key ? spanTag('key', keyName) + spanTag('mark', ': ') : '';
            const valueHtml = part.value ? buildValueHtml(part.value) : '';
            const endHtml = spanTag('mark', part.end);
            return indentHtml + keyHtml + valueHtml + endHtml;
        };
        const jsonLine = /^( *)("[^"]+": )?("[^"]*"|[\w.+-]*)?([{}[\],]*)?$/mg;
        const json = JSON.stringify(thing, null, settings.indent) || 'undefined';
        return htmlEntities(json).replace(jsonLine, replacer);
    },
};
