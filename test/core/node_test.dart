library tiles_node_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles.dart';
import '../mocks.dart';
import 'dart:async';


main() {

//  var component = new ComponentMock()
//    ..when(callsTo('render')).alwaysReturn([]);
//
//  component.getLogs(callsTo('componentWillReceiveProps')).verify(happenedOnce);
  group("(Node)", () {
    ComponentFactory factory = ({props, children}) => new Component(props);

    /**
     * test simple constructor and state after constructor was called
     */
    test("constructor", () {
      Node node = new Node(null, new ComponentMock(), factory);
      expect(node.component.props, equals(null));
      expect(node.component.children, equals(null));
      expect(node.isDirty, equals(true));
      expect(node.hasDirtyDescendant, equals(false));
      expect(node.children, isEmpty);
    });

    /**
     * test if constructor set parent path as has dirty descendant
     */
    test("constructor - set has dirty descendant to parent", () {
      Node node = new Node(null, new ComponentMock(), factory);
      Node node2 = new Node(node, new ComponentMock(), factory);

      expect(node.hasDirtyDescendant, equals(true));
    });

    /**
     * test simple update, with no children
     */
    test("update - check isDirty before and after", () {
      Node node = new Node(null, new ComponentMock(), factory);
      expect(node.isDirty, equals(true));

      node.update();
      expect(node.isDirty, equals(false));

    });

    test("should listen to components need update stream and set self as dirty if component need update", () {
      StreamController<bool> controller = new StreamController();
      ComponentMock component = new ComponentMock();
      component.when(callsTo("get needUpdate")).alwaysReturn(controller.stream);

      Node node = new Node(null, component, factory);
      node.update();

      expect(node.isDirty, isFalse);

      controller.add(true);
      controller.close().then((a) {
        expect(node.isDirty, isTrue);
      });
    });

    test("should accept ComponentDescription not in list from component.render()", () {
      ComponentMock component = new ComponentMock();
      component.when(callsTo("render")).alwaysReturn(new ComponentDescription(({dynamic props, children}) => new ComponentMock()));

      Node node = new Node(null, component, factory);
      node.update();
    });

  });

}
