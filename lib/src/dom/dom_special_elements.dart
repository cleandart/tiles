part of tiles_dom;

const _VALUE = "value";
const _CONTENT = "content";

class SpanComponent extends DomComponent {
  
  String _content;
  
  SpanComponent(DomProps props):
    _content = props[_CONTENT],
    super(props, null, "span") 
    {
    props.remove(_CONTENT);
    }
  
  set props(DomProps data) {
    _content = data[_CONTENT];
    data.remove(_CONTENT);
    super.props = data;
  }

  String content() => _content;

}

ComponentFactory _spanFactory = ([DomProps props]) => new SpanComponent(props);

ComponentDescriptionFactory _spanDescriptionFactory = ([dynamic props, dynamic children]) {
  /**
   * if props are Map, then cover it by DomProps
   */
  String content;
  
  if (children is String) {
    content = children;
    children =  null;
  }
  
  props = _putChildrenIntoProps(props, children);
  
  /**
   * if children was string, then now add content to props
   */
  if (content != null) {
    props[_CONTENT] = content;
  }
  
  return new ComponentDescription(_spanFactory,  props);
  
};

class TextareaComponent extends DomComponent {
  
  String _content;
  
  set props(DomProps data) {
    _content = data[_VALUE];
    data.remove(_VALUE);
    super.props = data;
  }

  TextareaComponent(DomProps props):
    this._content = props[_VALUE],
    super(props, null, "textarea") 
    {
    props.remove(_VALUE);
    }
  
  String content() => _content;

 
}

ComponentFactory _textareaFactory = ([DomProps props]) => new TextareaComponent(props);
