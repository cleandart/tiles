part of tiles_dom;

const _VALUE = "value";
const _CONTENT = "content";

class SpanComponent extends DomComponent {
  
  String _content;
  
  SpanComponent(Map props, List<ComponentDescription> children):
    _content = props[_CONTENT],
    super(props, children, null, "span") 
    {
    props.remove(_CONTENT);
    }
  
  set props(Map data) {
    _content = data[_CONTENT];
    data.remove(_CONTENT);
    super.props = data;
  }

  String content() => _content;

}

ComponentFactory _spanFactory = ([Map props, List<ComponentDescription> children]) => new SpanComponent(props, children);

ComponentDescriptionFactory _spanDescriptionFactory = ([dynamic props, dynamic children]) {
  /**
   * if props are Map, then cover it by Map
   */
  String content;
  
  if (children is String) {
    content = children;
    children =  null;
  }
  
  props = _processProps(props); 
  children = _processChildren(children);
  
  /**
   * if children was string, then now add content to props
   */
  if (content != null) {
    props[_CONTENT] = content;
  }
  
  return new ComponentDescription(_spanFactory,  props, children);
  
};

class TextareaComponent extends DomComponent {
  
  String _content;
  
  set props(Map data) {
    _content = data[_VALUE];
    data.remove(_VALUE);
    super.props = data;
  }

  TextareaComponent(Map props):
    this._content = props[_VALUE],
    super(props, null, null, "textarea") 
    {
    props.remove(_VALUE);
    }
  
  String content() => _content;

 
}

ComponentFactory _textareaFactory = ([Map props, children]) => new TextareaComponent(props);
