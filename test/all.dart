library tiles_test;

import "node_test.dart" as node;
import "component_description_test.dart" as componentDescription;
import "node_change_test.dart" as nodeChange;
import "props_test.dart" as props;
import "component_test.dart" as component;
import "dom_component_test.dart" as domComponent;
import "dom_elements_test.dart" as domElements;
import "dom_props_test.dart" as domProps;

main () {
  node.main();
  componentDescription.main();
  nodeChange.main();
  props.main();
  component.main();
  domComponent.main();
  domElements.main();
  domProps.main();
}
