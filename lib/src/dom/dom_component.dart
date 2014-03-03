part of tiles;

class DomComponent extends Component {
  final String tagName;
  final bool pair;
  
  Map _props;
  
  set props (Map data) {
    if (data != null) {
      _props = data;
    } else {
      _props = {};
    }
  }
  
  Map get props => _props;
  
  final bool svg;
  
  DomComponent([this._props, List<ComponentDescription> children, needUpdateController, this.tagName, pair, this.svg = false]):
      this.pair = pair == null || pair,
      super(null, children, needUpdateController){
    if (_props != null && !(_props is Map)) throw "Props should be map or string";
    if (_props == null) {
      _props = {};
    }
  }
  
  List<ComponentDescription> render() {
    return this.children;
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
