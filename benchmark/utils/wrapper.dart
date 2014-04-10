library tiles_react_wrapper;

import 'package:tiles/tiles.dart' as tiles;
import 'package:tiles/tiles_browser.dart' as tiles;
import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as react;
import 'dart:async';
import "dart:js";

class Component extends tiles.Component implements  react.Component {
  Component([props, children]): super(props, children);
  
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
  componentWillMount() {}

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
  getDefaultProps() {}
  
  @override
  getInitialState() {}
  
  @override
  bind(key) {
  }

  @override
  void componentDidUpdate(prevProps, prevState, rootNode) {
    didUpdate();
  }

  @override
  initComponentInternal(props, _jsRedraw, [ref = null]) {
  }

  @override
  initStateInternal() {
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
  registerComponent;

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



initTiles() {
  tiles.initTilesBrowserConfiguration();
  
  mountComponent = tiles.mountComponent;
  registerComponent = tiles.registerComponent;
  a = tiles.a;
  abbr = tiles.abbr;
  address = tiles.address;
  article = tiles.article;
  aside = tiles.aside;
  audio = tiles.audio;
  b = tiles.b;
  bdi = tiles.bdi;
  bdo = tiles.bdo;
  big = tiles.big;
  blockquote = tiles.blockquote;
  body = tiles.body;
  button = tiles.button;
  canvas = tiles.canvas;
  caption = tiles.caption;
  cite = tiles.cite;
  code = tiles.code;
  colgroup = tiles.colgroup;
  data = tiles.data;
  datalist = tiles.datalist;
  dd = tiles.dd;
  del = tiles.del;
  details = tiles.details;
  dfn = tiles.dfn;
  div = tiles.div;
  dl = tiles.dl;
  dt = tiles.dt;
  em = tiles.em;
  fieldset = tiles.fieldset;
  figcaption = tiles.figcaption;
  figure = tiles.figure;
  footer = tiles.footer;
  form = tiles.form;
  h1 = tiles.h1;
  h2 = tiles.h2;
  h3 = tiles.h3;
  h4 = tiles.h4;
  h5 = tiles.h5;
  h6 = tiles.h6;
  head = tiles.head;
  header = tiles.header;
  html = tiles.html;
  i = tiles.i;
  iframe = tiles.iframe;
  ins = tiles.ins;
  kbd = tiles.kbd;
  label = tiles.label;
  legend = tiles.legend;
  li = tiles.li;
  main = tiles.main;
  map = tiles.map;
  mark = tiles.mark;
  menu = tiles.menu;
  menuitem = tiles.menuitem;
  meter = tiles.meter;
  nav = tiles.nav;
  noscript = tiles.noscript;
  object = tiles.object;
  ol = tiles.ol;
  optgroup = tiles.optgroup;
  option = tiles.option;
  output = tiles.output;
  p = tiles.p;
  pre = tiles.pre;
  progress = tiles.progress;
  q = tiles.q;
  rp = tiles.rp;
  rt = tiles.rt;
  ruby = tiles.ruby;
  s = tiles.s;
  samp = tiles.samp;
  script = tiles.script;
  section = tiles.section;
  select = tiles.select;
  small = tiles.small;
  span = tiles.span;
  strong = tiles.strong;
  style = tiles.style;
  sub = tiles.sub;
  summary = tiles.summary;
  sup = tiles.sup;
  table = tiles.table;
  tbody = tiles.tbody;
  td = tiles.td;
  textarea = tiles.textarea;
  tfoot = tiles.tfoot;
  th = tiles.th;
  thead = tiles.thead;
  time = tiles.time;
  title = tiles.title;
  tr = tiles.tr;
  u = tiles.u;
  ul = tiles.ul;
  /**
   * we need to use varElement
   * because var is reserved keyword
   */
  varElement = tiles.varElement;
  video = tiles.video;

  /** SVG ELEMENTS */
  g = tiles.g;
  svg = tiles.svg;
  text = tiles.text;

  /** NOT PAIR ELEMENTS */
  area = tiles.area;
  base = tiles.base;
  br = tiles.br;
  col = tiles.col;
  embed = tiles.embed;
  hr = tiles.hr;
  img = tiles.img;
  input = tiles.input;
  keygen = tiles.keygen;
  link = tiles.link;
  meta = tiles.meta;
  param = tiles.param;
  /**
   * Command is not in react
   * param = registerDomComponent("param"; false);
   */
  source = tiles.source;
  track = tiles.track;
  wbr = tiles.wbr;

  /** SVG NOT PAIR ELEMENTS */
  circle = tiles.circle;
  line = tiles.line;
  path = tiles.path;
  polyline = tiles.polyline;
  rect = tiles.rect;


}
typedef JsObject _Factory({props, children});
initReact() {
  react.setClientConfiguration();

  mountComponent = react.renderComponent;
  registerComponent = (_Factory factory) {
    react.ReactComponentFactory reactFactory = ([Map props, dynamic children]) => factory(props: props, children: children);
    var registeredComponent = react.registerComponent(reactFactory);
    return ({props, children, key, Map listeners}) {
      if(!(props is Map)) {
        props = {};
      }
      if(listeners is Map) {
        props.addAll(listeners);
      }
      props["key"] = key;
      return registeredComponent(props, children);
    };
  };
  a = _ReactElementToTiles(react.a);
  abbr = _ReactElementToTiles(react.abbr);
  address = _ReactElementToTiles(react.address);
  article = _ReactElementToTiles(react.article);
  aside = _ReactElementToTiles(react.aside);
  audio = _ReactElementToTiles(react.audio);
  b = _ReactElementToTiles(react.b);
  bdi = _ReactElementToTiles(react.bdi);
  bdo = _ReactElementToTiles(react.bdo);
  big = _ReactElementToTiles(react.big);
  blockquote = _ReactElementToTiles(react.blockquote);
  body = _ReactElementToTiles(react.body);
  button = _ReactElementToTiles(react.button);
  canvas = _ReactElementToTiles(react.canvas);
  caption = _ReactElementToTiles(react.caption);
  cite = _ReactElementToTiles(react.cite);
  code = _ReactElementToTiles(react.code);
  colgroup = _ReactElementToTiles(react.colgroup);
  data = _ReactElementToTiles(react.data);
  datalist = _ReactElementToTiles(react.datalist);
  dd = _ReactElementToTiles(react.dd);
  del = _ReactElementToTiles(react.del);
  details = _ReactElementToTiles(react.details);
  dfn = _ReactElementToTiles(react.dfn);
  div = _ReactElementToTiles(react.div);
  dl = _ReactElementToTiles(react.dl);
  dt = _ReactElementToTiles(react.dt);
  em = _ReactElementToTiles(react.em);
  fieldset = _ReactElementToTiles(react.fieldset);
  figcaption = _ReactElementToTiles(react.figcaption);
  figure = _ReactElementToTiles(react.figure);
  footer = _ReactElementToTiles(react.footer);
  form = _ReactElementToTiles(react.form);
  h1 = _ReactElementToTiles(react.h1);
  h2 = _ReactElementToTiles(react.h2);
  h3 = _ReactElementToTiles(react.h3);
  h4 = _ReactElementToTiles(react.h4);
  h5 = _ReactElementToTiles(react.h5);
  h6 = _ReactElementToTiles(react.h6);
  head = _ReactElementToTiles(react.head);
  header = _ReactElementToTiles(react.header);
  html = _ReactElementToTiles(react.html);
  i = _ReactElementToTiles(react.i);
  iframe = _ReactElementToTiles(react.iframe);
  ins = _ReactElementToTiles(react.ins);
  kbd = _ReactElementToTiles(react.kbd);
  label = _ReactElementToTiles(react.label);
  legend = _ReactElementToTiles(react.legend);
  li = _ReactElementToTiles(react.li);
  main = _ReactElementToTiles(react.main);
  map = _ReactElementToTiles(react.map);
  mark = _ReactElementToTiles(react.mark);
  menu = _ReactElementToTiles(react.menu);
  menuitem = _ReactElementToTiles(react.menuitem);
  meter = _ReactElementToTiles(react.meter);
  nav = _ReactElementToTiles(react.nav);
  noscript = _ReactElementToTiles(react.noscript);
  object = _ReactElementToTiles(react.object);
  ol = _ReactElementToTiles(react.ol);
  optgroup = _ReactElementToTiles(react.optgroup);
  option = _ReactElementToTiles(react.option);
  output = _ReactElementToTiles(react.output);
  p = _ReactElementToTiles(react.p);
  pre = _ReactElementToTiles(react.pre);
  progress = _ReactElementToTiles(react.progress);
  q = _ReactElementToTiles(react.q);
  rp = _ReactElementToTiles(react.rp);
  rt = _ReactElementToTiles(react.rt);
  ruby = _ReactElementToTiles(react.ruby);
  s = _ReactElementToTiles(react.s);
  samp = _ReactElementToTiles(react.samp);
  script = _ReactElementToTiles(react.script);
  section = _ReactElementToTiles(react.section);
  select = _ReactElementToTiles(react.select);
  small = _ReactElementToTiles(react.small);
  span = _ReactElementToTiles(react.span);
  strong = _ReactElementToTiles(react.strong);
  style = _ReactElementToTiles(react.style);
  sub = _ReactElementToTiles(react.sub);
  summary = _ReactElementToTiles(react.summary);
  sup = _ReactElementToTiles(react.sup);
  table = _ReactElementToTiles(react.table);
  tbody = _ReactElementToTiles(react.tbody);
  td = _ReactElementToTiles(react.td);
  textarea = _ReactElementToTiles(react.textarea);
  tfoot = _ReactElementToTiles(react.tfoot);
  th = _ReactElementToTiles(react.th);
  thead = _ReactElementToTiles(react.thead);
  time = _ReactElementToTiles(react.time);
  title = _ReactElementToTiles(react.title);
  tr = _ReactElementToTiles(react.tr);
  u = _ReactElementToTiles(react.u);
  ul = _ReactElementToTiles(react.ul);
  /**
   * we need to use varElement
   * because var is reserved keyword
   */
  varElement = _ReactElementToTiles(react.variable);
  video = _ReactElementToTiles(react.video);

  /** SVG ELEMENTS */
  g = _ReactElementToTiles(react.g);
  svg = _ReactElementToTiles(react.svg);
  text = _ReactElementToTiles(react.text);

  /** NOT PAIR ELEMENTS */
  area = _ReactElementToTiles(react.area);
  base = _ReactElementToTiles(react.base);
  br = _ReactElementToTiles(react.br);
  col = _ReactElementToTiles(react.col);
  embed = react.embed;
  hr = _ReactElementToTiles(react.hr);
  img = _ReactElementToTiles(react.img);
  input = _ReactElementToTiles(react.input);
  keygen = _ReactElementToTiles(react.keygen);
  link = _ReactElementToTiles(react.link);
  meta = _ReactElementToTiles(react.meta);
  param = _ReactElementToTiles(react.param);
  /**
   * Command is not in react
   * param = registerDomComponent("param"; false);
   */
  source = _ReactElementToTiles(react.source);
  track = _ReactElementToTiles(react.track);
  wbr = _ReactElementToTiles(react.wbr);

  /** SVG NOT PAIR ELEMENTS */
  circle = _ReactElementToTiles(react.circle);
  line = _ReactElementToTiles(react.line);
  path = _ReactElementToTiles(react.path);
  polyline = _ReactElementToTiles(react.polyline);
  rect = _ReactElementToTiles(react.rect);
}

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
