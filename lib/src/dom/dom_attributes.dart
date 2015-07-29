library tiles.core.restrictions;

/**
 * Returns boolean which is true
 * if attribute with passed key can be added
 * to element of component from arguments.
 */
canAddAttribute(bool svg, String key) {
  return (!svg && allowedAttrs.contains(key))
      || (svg && allowedSvgAttributes.contains(key)) 
      || _matchAllowedPrefix(key);

}

/**
 * tells if the key match some of allowed prefixes
 */
bool _matchAllowedPrefix(String key) {
  bool match = false;
  
  allowedAttrsPrefixes.forEach((prefix) {
    if (key.startsWith(prefix)) {
      match = true;
    }
  });

  return match;
}

final Set<String> allowedAttrs = new Set.from([
  "accept",
  "accessKey",
  "action",
  "allowFullScreen",
  "allowTransparency",
  "alt",
  "async",
  "autoCapitalize",
  "autoComplete",
  "autoFocus",
  "autoPlay",
  "cellPadding",
  "cellSpacing",
  "charSet",
  "checked",
  "class",
  "cols",
  "colSpan",
  "content",
  "contentEditable",
  "contextMenu",
  "controls",
  "data",
  "dateTime",
  "dir",
  "disabled",
  "draggable",
  "encType",
  "for",
  "form",
  "frameBorder",
  "height",
  "hidden",
  "href",
  "htmlFor",
  "httpEquiv",
  "icon",
  "id",
  "label",
  "lang",
  "list",
  "loop",
  "max",
  "maxLength",
  "method",
  "min",
  "multiple",
  "name",
  "pattern",
  "placeholder",
  "poster",
  "preload",
  "radioGroup",
  "readOnly",
  "rel",
  "required",
  "role",
  "rows",
  "rowSpan",
  "scrollLeft",
  "scrollTop",
  "selected",
  "size",
  "spellCheck",
  "src",
  "step",
  "style",
  "tabIndex",
  "target",
  "title",
  "type",
  "value",
  "defaultValue",
  "width",
  "wmode"
]);

final Set<String> allowedSvgAttributes = new Set.from([
  "cx",
  "cy",
  "d",
  "fill",
  "fx",
  "fy",
  "gradientTransform",
  "gradientUnits",
  "offset",
  "points",
  "r",
  "rx",
  "ry",
  "spreadMethod",
  "stopColor",
  "stopOpacity",
  "stroke",
  "strokeLinecap",
  "strokeWidth",
  "transform",
  "version",
  "viewBox",
  "x1",
  "x2",
  "x",
  "y1",
  "y2",
  "y"
]);

final Set<String> allowedAttrsPrefixes = new Set.from(["data-", "aria-"]);

const VALUE = "value";
const DEFAULTVALUE = "defaultValue";
