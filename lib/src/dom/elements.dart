part of tiles_dom;

/**
 * specialized registerComponent method, which by tagname and pair flag 
 * create according factory for html elements
 * 
 * @param String tagname tag name of final html element
 * @param bool   pair    parity of final html element
 * @return ComponentDescriptionFactory which contains ComponentFactory to create DomCommponent 
 */
ComponentDescriptionFactory _registerDomComponent(String tagname, [bool pair, bool svg = false]) {
  
  /** create factory which create DomComponent */
  var factory = ([dynamic props]) => new DomComponent(props, null, tagname, pair, svg);
  
  /**  
   * return ComponentDescription similar to that, 
   * which return registerComponent, 
   * but with small difference in proccessing props, which in this case can be Map too.
   */
  return ([dynamic props, List<ComponentDescription> children]) {
    /**
     * if props are Map, then cover it by DomProps
     */
    if (props is Map) {
      props = new DomProps(props);
    }    

    /**
     * if we have props and also children, 
     * we add children to props
     */
    if (props != null && children != null) {
      props._children = children;
    }
    
    /**
     * if props are null but we have children, 
     * wee need to add chilren to some props, so we create them
     */
    if (props == null && children != null) {
      props = new DomProps(null, children);
    }
    
    if (props != null && !(props is Props)) {
      throw "props should be instance of DomProps, Map or null";
    }
    
    return new ComponentDescription(factory, props);
  };

}

/**
 * for now, function _registerSvgComponent do the same, as _registerDomComponent
 */
ComponentDescriptionFactory _registerSvgComponent(String tagname, [bool pair]) {
  return _registerDomComponent(tagname, pair, true);
}

/**
 * create all standart html elements as description factory which create DomComponent
 */
ComponentDescriptionFactory a = _registerDomComponent("a"),
  abbr = _registerDomComponent("abbr"),
  address = _registerDomComponent("address"),
  article = _registerDomComponent("article"),
  aside = _registerDomComponent("aside"),
  audio = _registerDomComponent("audio"),
  b = _registerDomComponent("b"),
  bdi = _registerDomComponent("bdi"),
  bdo = _registerDomComponent("bdo"),
  big = _registerDomComponent("big"),
  blockquote = _registerDomComponent("blockquote"),
  body = _registerDomComponent("body"),
  button = _registerDomComponent("button"),
  canvas = _registerDomComponent("canvas"),
  caption = _registerDomComponent("caption"),
  cite = _registerDomComponent("cite"),
  code = _registerDomComponent("code"),
  colgroup = _registerDomComponent("colgroup"),
  data = _registerDomComponent("data"),
  datalist = _registerDomComponent("datalist"),
  dd = _registerDomComponent("dd"),
  del = _registerDomComponent("del"),
  details = _registerDomComponent("details"),
  dfn = _registerDomComponent("dfn"),
  div = _registerDomComponent("div"),
  dl = _registerDomComponent("dl"),
  dt = _registerDomComponent("dt"),
  em = _registerDomComponent("em"),
  fieldset = _registerDomComponent("fieldset"),
  figcaption = _registerDomComponent("figcaption"),
  figure = _registerDomComponent("figure"),
  footer = _registerDomComponent("footer"),
  form = _registerDomComponent("form"),
  h1 = _registerDomComponent("h1"),
  h2 = _registerDomComponent("h2"),
  h3 = _registerDomComponent("h3"),
  h4 = _registerDomComponent("h4"),
  h5 = _registerDomComponent("h5"),
  h6 = _registerDomComponent("h6"),
  head = _registerDomComponent("head"),
  header = _registerDomComponent("header"),
  html = _registerDomComponent("html"),
  i = _registerDomComponent("i"),
  iframe = _registerDomComponent("iframe"),
  ins = _registerDomComponent("ins"),
  kbd = _registerDomComponent("kbd"),
  label = _registerDomComponent("label"),
  legend = _registerDomComponent("legend"),
  li = _registerDomComponent("li"),
  main = _registerDomComponent("main"),
  map = _registerDomComponent("map"),
  mark = _registerDomComponent("mark"),
  menu = _registerDomComponent("menu"),
  menuitem = _registerDomComponent("menuitem"),
  meter = _registerDomComponent("meter"),
  nav = _registerDomComponent("nav"),
  noscript = _registerDomComponent("noscript"),
  object = _registerDomComponent("object"),
  ol = _registerDomComponent("ol"),
  optgroup = _registerDomComponent("optgroup"),
  option = _registerDomComponent("option"),
  output = _registerDomComponent("output"),
  p = _registerDomComponent("p"),
  pre = _registerDomComponent("pre"),
  progress = _registerDomComponent("progress"),
  q = _registerDomComponent("q"),
  rp = _registerDomComponent("rp"),
  rt = _registerDomComponent("rt"),
  ruby = _registerDomComponent("ruby"),
  s = _registerDomComponent("s"),
  samp = _registerDomComponent("samp"),
  script = _registerDomComponent("script"),
  section = _registerDomComponent("section"),
  select = _registerDomComponent("select"),
  small = _registerDomComponent("small"),
  span = _registerDomComponent("span"),
  strong = _registerDomComponent("strong"),
  style = _registerDomComponent("style"),
  sub = _registerDomComponent("sub"),
  summary = _registerDomComponent("summary"),
  sup = _registerDomComponent("sup"),
  table = _registerDomComponent("table"),
  tbody = _registerDomComponent("tbody"),
  td = _registerDomComponent("td"),
  textarea = _registerDomComponent("textarea"),
  tfoot = _registerDomComponent("tfoot"),
  th = _registerDomComponent("th"),
  thead = _registerDomComponent("thead"),
  time = _registerDomComponent("time"),
  title = _registerDomComponent("title"),
  tr = _registerDomComponent("tr"),
  u = _registerDomComponent("u"),
  ul = _registerDomComponent("ul"),
  /**
   * we need to use varElement 
   * because var is reserved keyword
   */
  varElement = _registerDomComponent("var"),
  video = _registerDomComponent("video"),
  
  /** SVG ELEMENTS */
  g = _registerSvgComponent("g"), 
  svg = _registerSvgComponent("svg"), 
  text = _registerSvgComponent("text"),
  
  /** NOT PAIR ELEMENTS */
  area = _registerDomComponent("area", false),
  base = _registerDomComponent("base", false),
  br = _registerDomComponent("br", false),
  col = _registerDomComponent("col", false),
  embed = _registerDomComponent("embed", false),
  hr = _registerDomComponent("hr", false),
  img = _registerDomComponent("img", false),
  input = _registerDomComponent("input", false),
  keygen = _registerDomComponent("keygen", false),
  link = _registerDomComponent("link", false),
  meta = _registerDomComponent("meta", false),
  param = _registerDomComponent("param", false),
  /** 
   * Command is not in react
   * param = registerDomComponent("param", false),
   */
  source = _registerDomComponent("source", false),
  track = _registerDomComponent("track", false),
  wbr = _registerDomComponent("wbr", false),
  
  /** SVG NOT PAIR ELEMENTS */
  circle = _registerSvgComponent("circle", false),  
  line = _registerSvgComponent("line", false), 
  path = _registerSvgComponent("path", false), 
  polyline = _registerSvgComponent("polyline", false), 
  rect = _registerSvgComponent("rect", false);
  

