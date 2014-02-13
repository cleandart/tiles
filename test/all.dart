library tiles_test;

import "core/node_test.dart" as node;
import "core/component_description_test.dart" as componentDescription;
import "core/node_change_test.dart" as nodeChange;
import "core/component_test.dart" as component;
import "dom/dom_component_test.dart" as domComponent;
import "dom/dom_elements_test.dart" as domElements;
import "dom/dom_elements_special_test.dart" as domElementsSpecial;
import "dom/dom_text_component_test.dart" as domTextComponent;
import 'browser/mount_component_test.dart' as mountComponent;

main () {
  node.main();
  componentDescription.main();
  nodeChange.main();
  component.main();
  domComponent.main();
  domElements.main();
  domElementsSpecial.main();
  domTextComponent.main();
  mountComponent.main();
}
