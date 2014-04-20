import 'common/component.dart';
import 'utils/utils.dart';
import 'dart:html';

main() {
  var localSettings = getSettingsFromHash();
  if(localSettings["library"] == "react") {
    initReact();
  } else {
    initTiles();
  }
    
  
  Element element = querySelector("#container");
  var description = component(props: {"levels": localSettings["levels"], "level": 0, "prefix": "runner"});
  
  if(localSettings["environment"] == "virtual") {
    createVirtualDOM(description, null);
  } else {
    mountComponent(description, element);
  }
  
  printResults();
}