part of utils;

class Component extends tiles.Component implements  react.Component {
  Component([props, children]): super(props, children);
  
  @override
  Map props;
  
  dynamic _jsRedraw;


  
  @override
  dynamic ref;
  
  @override
  dynamic state;
  
  @override
  dynamic nextState;
  
  @override
  setState(_) {
    redraw();
  }
  
  @override
  replaceState(_) {
    redraw();
  }
  
  @override
  componentWillMount() {
  }

  @override
  componentDidMount(_) {
    didMount();
  }

  @override
  componentWillReceiveProps(_) {
    willReceiveProps(_);
  }
  
  @override
  componentWillUpdate(_, __){}
  
  @override
  componentWillUnmount() {
    willUnmount();
  }
  
  @override
  getDefaultProps() => {};
  
  @override
  getInitialState() => {};
  
  @override
  bind(key) {
  }

  @override
  void componentDidUpdate(prevProps, prevState, rootNode) {
    didUpdate();
  }

  @override
  initComponentInternal(props, _jsRedraw, [ref = null]) {
    this._jsRedraw = _jsRedraw;
    this.ref = ref;
    _initProps(props);
  }
  
  _initProps(props) {
    this.props = {}
      ..addAll(getDefaultProps())
      ..addAll(props);
  }

  @override
  initStateInternal() {
    this.state = new Map.from(getInitialState());
    /** Call transferComponent to get state also to _prevState */
    transferComponentState();
  }



  @override
  Map get prevState => null;

  @override
  bool shouldComponentUpdate(nextProps, nextState) {
    return shouldUpdate(prevState, nextState);
  }

  @override
  void transferComponentState() {
  }
}

var mountComponent,
  registerComponent,
  createVirtualDOM;

Benchmark benchmark;

var a, abbr, address, area, article, aside, audio, b, base, bdi, bdo, big, blockquote, body, br,
button, canvas, caption, cite, code, col, colgroup, data, datalist, dd, del, details, dfn,
div, dl, dt, em, embed, fieldset, figcaption, figure, footer, form, h1, h2, h3, h4, h5, h6,
head, header, hr, html, i, iframe, img, input, ins, kbd, keygen, label, legend, li, link, main,
map, mark, menu, menuitem, meta, meter, nav, noscript, object, ol, optgroup, option, output,
p, param, pre, progress, q, rp, rt, ruby, s, samp, script, section, select, small, source,
span, strong, style, sub, summary, sup, table, tbody, td, textarea, tfoot, th, thead, time,
title, tr, track, u, ul, varElement , video, wbr;

/** SVG elements */
var circle, g, line, path, polyline, rect, svg, text;




_ReactElementToTiles(element){
  return ({props, children, key, listeners}) {
    if(!(props is Map)) {
      props = {};
    }
    if (listeners is Map) {
      props.addAll(listeners);
    }
    props["key"] = key;
   return element(props, children); 
  };
}
typedef JsObject _Factory({props, children});
