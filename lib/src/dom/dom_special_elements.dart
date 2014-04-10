part of tiles;

const _VALUE = "value";

class TextareaComponent extends DomComponent {

  TextareaComponent(Map props):
    super(props, null, "textarea");

  render() => null;
}

ComponentFactory _textareaFactory = ([Map props, children]) => new TextareaComponent(props);
