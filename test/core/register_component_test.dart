library tiles_register_component_test;

import 'package:unittest/unittest.dart';
import 'package:tiles/tiles.dart';
import '../mocks.dart';
import 'package:unittest/mock.dart';


main() {
  group("(registerComponent", () {
    test("should register component factory", () {
      var factory = registerComponent(([props, children]) => new ComponentMock());
      expect(factory is ComponentDescriptionFactory, isTrue);
    });

    test("should create component description factory, which can produce component description with props, children and key", () {
      ComponentDescriptionFactory factory = registerComponent(([props, children]) => new ComponentMock());
      var props = new Mock();
      var children = [new ComponentDescriptionMock()];
      var key = "key";
      ComponentDescription description = factory(props: props, children: children, key: key);

      expect(description.props, equals(props));
      expect(description.children, equals(children));
      expect(description.key, equals(key));
    });

  });
}

