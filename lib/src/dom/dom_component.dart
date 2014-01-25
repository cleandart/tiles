part of tiles_dom;

const _OPENMARK = "<";
const _CLOSEMARK = ">";
const _CLOSESIGN = "/";

class DomComponent extends Component {
  final String _tagName;
  final bool _pair;
  
  DomProps props; 
  
  bool get pair => _pair;
  
  final bool svg;
  
  DomComponent(DomProps this.props, [needUpdateController, this._tagName, pair, this.svg = false]):
    this._pair = pair == null || pair,
    super(null, needUpdateController) 
    {}
  
  /**
   * generate open markup from tagname and props
   * 
   * if this component is not pair html element, then create self-closing tag
   */
  String openMarkup() {
    StringBuffer result = new StringBuffer("$_OPENMARK$_tagName");
    
    if (props != null) {
      result.write(props.htmlAttrs(this.svg));
    }
    
    result.write("${_pair ? "" : " $_CLOSESIGN"}$_CLOSEMARK");
    return result.toString();
  }
  
  /**
   * if component corespond with pair element, return close markup, else return null
   */
  String closeMarkup() => _pair ? "$_OPENMARK$_CLOSESIGN$_tagName$_CLOSEMARK" : null;
  
  List<ComponentDescription> render() {
    if (props != null) {
      return props.children;
    }
    return null;
  }
  
}

