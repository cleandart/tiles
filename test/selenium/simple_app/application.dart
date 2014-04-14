import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';

main() {
  initTilesBrowserConfiguration();

  Element divEl = new DivElement();
  querySelector("body").append(divEl);

  mountComponent(inputComponent(), divEl);
}

class InputComponent extends Component {
  InputComponent([props, children]): super(props, children);

  String text = "";

  render() {
    return div(props: {}, children: [
      input(props: {
        "type": "text",
        "defaultValue": text,
        "ref": inputRef,
        "onKeyUp": inputKeyUp
      }),
      label(props: {
        "id": text,
        "onClick": labelClick
        }, children: text)
    ]);
  }

  bool inputKeyUp(Component component, Event event) {
    InputElement inputElement = getElementForComponent(component);

    this.text = inputElement.value;
    this.redraw();
    return true;
  }

  void inputRef(Component component) {
    this.myInput = component;
  }

  bool labelClick(Component component, Event event) {
    this.text = "";
    this.redraw();
    return true;
  }

  Component myInput;
}

ComponentDescriptionFactory inputComponent = registerComponent(({props, List<ComponentDescription> children}) => new InputComponent(props, children));

