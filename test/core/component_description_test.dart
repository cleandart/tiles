library tiles_compoenent_description_test;

import 'package:unittest/unittest.dart';
import 'package:tiles/tiles.dart';
import '../mocks.dart';
import 'package:unittest/mock.dart';

main() {
  group("(ComponentDescription)", () {
    test("constructor (create with factory, props and children and then check if there is", () {

      Component component = new ComponentMock();
      ComponentFactory factory = ([props, children]) => null;
      dynamic props = new Mock();
      var children = [new ComponentDescriptionMock()];

      ComponentDescription description = new ComponentDescription(factory, props, children);

      expect(description.factory, equals(factory));
      expect(description.props, equals(props));
      expect(description.children, equals(children));
    });

    test("createComponent should call factory with this.props and this.children", () {

      ComponentMock component = new ComponentMock();

      /**
       * flag, if factory was called
       */

      bool called = false;
      dynamic testProps = null;
      List<ComponentDescription> testChildren = null;
      /**
       * factory allways return above component and set called to true
       */
      ComponentFactory factory = ([dynamic props, List<ComponentDescription> children]) {
        called = true;
        testChildren = children;
        testProps = props;
        return component;
      };

      dynamic props = new Mock();
      List<ComponentDescription> children = [new ComponentDescriptionMock()];

      ComponentDescription description = new ComponentDescription(factory, props, children);

      expect(description.createComponent(), equals(component));
      expect(testProps, equals(props));
      expect(testChildren, equals(children));
      expect(called, isTrue);
    });

    test("should have readonly props", () {
      ComponentDescription description = new ComponentDescription(([props, children]) => null);
      expect(() {description.props = null;}, throws);
    });

    test("should have readonly children", () {
      ComponentDescription description = new ComponentDescription(([props, children]) => null);
      expect(() {description.children = null;}, throws);
    });

    test("should have no key by default", () {
      ComponentDescription description = new ComponentDescription(([props, children]) => null);
      expect(description.key, isNull);
    });

    test("should have key optionali added in constructor", () {
      var key = new Mock();

      ComponentDescription description = new ComponentDescription(([props, children]) => null, null, null, key);

      expect(description.key, equals(key));
    });

  });

}
