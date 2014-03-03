part of tiles_dom;

const _OPENMARK = "<";
const _CLOSEMARK = ">";
const _CLOSESIGN = "/";

class DomComponent extends Component {
  final String _tagName;
  final bool _pair;
  
  Map props; 
  
  bool get pair => _pair;
  
  final bool svg;
  
  DomComponent([this.props, List<ComponentDescription> children, needUpdateController, this._tagName, pair, this.svg = false]):
    this._pair = pair == null || pair,
    super(null, children, needUpdateController) 
    {}
  
  /**
   * generate open markup from tagname and props
   * 
   * if this component is not pair html element, then create self-closing tag
   */
  String openMarkup() {
    StringBuffer result = new StringBuffer("$_OPENMARK$_tagName");
    
    if (props != null) {
      result.write(htmlAttrs(props, this.svg));
    }
    
    result.write("${_pair ? "" : " $_CLOSESIGN"}$_CLOSEMARK");
    return result.toString();
  }
  
  /**
   * if component corespond with pair element, return close markup, else return null
   */
  String closeMarkup() => _pair ? "$_OPENMARK$_CLOSESIGN$_tagName$_CLOSEMARK" : null;
  
  List<ComponentDescription> render() {
    return this.children;
  }
  
  /**
   * Html attributes generator. 
   * 
   * Generate attributes in html syntas attr="value" for future use in DomComponent.
   */
  String htmlAttrs(Map map, [bool svg = false]) {
    StringBuffer result = new StringBuffer();
    
    map.forEach((String key, dynamic value) {
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
