library tiles_test;

import "core/node_test.dart" as node;
import "core/node_update_children_test.dart" as nodeUpdateChildren;
import "core/component_description_test.dart" as componentDescription;
import "core/node_change_test.dart" as nodeChange;
import "core/component_test.dart" as component;
import "core/register_component_test.dart" as registerComponent;
import "dom/dom_component_test.dart" as domComponent;
import "dom/dom_elements_test.dart" as domElements;
import "dom/dom_elements_special_test.dart" as domElementsSpecial;
import "dom/dom_text_component_test.dart" as domTextComponent;

main () {
  component.main();
  registerComponent.main();

  componentDescription.main();
  nodeChange.main();
  node.main();
  nodeUpdateChildren.main();

  domComponent.main();
  domElements.main();
  domElementsSpecial.main();
  domTextComponent.main();
}
