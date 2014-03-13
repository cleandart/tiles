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
    return div({}, [
      input({
        "type": "text", 
        "value": text, 
        "ref": inputRef,
        "onKeyUp": inputKeyUp
      }),
      label({
        "id": text,
        "onClick": labelClick
        }, text)
    ]);
  }
  
  void inputKeyUp(Component component, Event event) {
    InputElement inputElement = getElementForComponent(component);
    
    this.text = inputElement.value;
    this.redraw();
  }
  
  void inputRef(Component component) {
    this.myInput = component;
  }
  
  void labelClick(Component component, Event event) {
    this.text = "";
    this.redraw();
  }
  
  Component myInput;
}

ComponentDescriptionFactory inputComponent = registerComponent(([props, List<ComponentDescription> children]) => new InputComponent(props, children));

