part of tiles_dom;


class DomProps extends Props implements Map<String, dynamic> {

  /**
   * because of constructor, it needs own implementation of _children
   */
  List<ComponentDescription> _children;

  final Map<String, dynamic> _map;
  
  /**
   * getter for children. 
   */
  List<ComponentDescription> get children => _children;
  
  DomProps([Map map, List<ComponentDescription> children]):
    this._children = children != null ? children : (map != null ? map["children"] : null), 
    this._map = map != null ? map : new Map()
    {}
  
  
  
  /**
   * proxy getters and operations for map
   */
  
  Iterable<String> get keys => _map.keys;
  
  bool get isEmpty => _map.isEmpty;
  
  int get length => _map.length;
  
  Iterable<dynamic> get values => _map.values;

  remove(String key) => _map.remove(key);
  
  bool get isNotEmpty => _map.isNotEmpty;
  
  putIfAbsent(key, callback) => _map.putIfAbsent(key, callback);
  
  forEach(function) => _map.forEach(function);
  
  addAll(DomProps props) => _map.addAll(props._map);
  
  clear() => _map.clear();
  
  bool containsKey(String key) => _map.containsKey(key);
  
  bool containsValue(dynamic value) => _map.containsValue(value);
 
  operator [](String key) => _map[key];
  
  void operator []=(String key, dynamic value) {
    _map[key] = value;
  }
  
  
  /**
   * Html attributes generator. 
   * 
   * Generate attributes in html syntas attr="value" for future use in DomComponent.
   */
  String htmlAttrs([bool svg = false]) {
    StringBuffer result = new StringBuffer();
    
    _map.forEach((String key, dynamic value) {
      if (!svg && _allowedAttrs.contains(key)) {
        result.write(' $key="$value"');
      } else if (svg && _allowedSvgAttributes.contains(key)) {
        result.write(' $key="$value"');
      }
    });
    
    return result.toString();
  }
}


Set<String> _allowedAttrs = new Set.from(["accept", "accessKey", "action", "allowFullScreen", "allowTransparency", "alt", "autoCapitalize",
	"autoComplete", "autoFocus", "autoPlay", "cellPadding", "cellSpacing", "charSet", "checked",
	"className", "colSpan", "content", "contentEditable", "contextMenu", "controls", "data", "dateTime",
	"dir", "disabled", "draggable", "encType", "form", "frameBorder", "height", "hidden", "href", "htmlFor",
	"httpEquiv", "icon", "id", "label", "lang", "list", "loop", "max", "maxLength", "method", "min", "multiple", "name",
	"pattern", "placeholder", "poster", "preload", "radioGroup", "readOnly", "rel", "required", "role",
	"rowSpan", "scrollLeft", "scrollTop", "selected", "size", "spellCheck", "src", "step", "style", "tabIndex",
	"target", "title", "type", "value", "width", "wmode"]);

Set<String> _allowedSvgAttributes = new Set.from(["cx", "cy", "d", "fill", "fx", "fy", "gradientTransform", 
	"gradientUnits", "offset", "points", "r", "rx", "ry",
	"spreadMethod", "stopColor", "stopOpacity", "stroke", "strokeLinecap", "strokeWidth", "transform",
	"version", "viewBox", "x1", "x2", "x", "y1", "y2", "y"]);
