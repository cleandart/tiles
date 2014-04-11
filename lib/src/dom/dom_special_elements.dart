part of tiles;

const _VALUE = "value";

class TextareaComponent extends DomComponent {

  String _content;

  set props(Map data) {
    _content = data[_VALUE];
    data.remove(_VALUE);
    super.props = data;
  }

  TextareaComponent(Map props):
    this._content = props[_VALUE],
    super(props, null, "textarea")
    {
    props.remove(_VALUE);
    }

  String content() => _content;


}

ComponentFactory _textareaFactory = ([Map props, children]) => new TextareaComponent(props);
