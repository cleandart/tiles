library tiles_node_test;

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:tiles/tiles.dart';
import '../mocks.dart';
import 'dart:async';


main() {

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
      when(component.needUpdate).thenReturn(controller.stream);

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
      when(component.render()).thenReturn(new ComponentDescription(({dynamic props, children}) => new ComponentMock()));

      Node node = new Node(null, component, factory);
      node.update();
    });

    test("should correctly create node from description", () {
      Map listeners = {1: 1};
      ComponentMock component = new ComponentMock();
      var calledProps, calledChildren;
      ComponentFactory factory = ({props, children}) {
        calledChildren = children;
        calledProps = props;
        return component;
      };
      var key = "key";
      var props = new Mock();
      var children = [new ComponentMock()];

      ComponentDescription description = new ComponentDescription(factory, props: props, children: children, key: key, listeners: listeners);

      Node node = new Node.fromDescription(null, description);

      expect(node.factory, equals(factory));
      expect(node.key, equals(key));
      expect(node.component, equals(component));
      expect(calledProps, equals(props));
      expect(calledChildren, equals(children));
      expect(node.listeners, equals(listeners));
    });

    test("should create node with listeners, when in constructor", () {
      var listeners = {1: new Mock()};
      Node node = new Node(null, new ComponentMock(), null, listeners: listeners);

      expect(node.listeners, equals(listeners));
    });

    test("should add new listeners, when applied", () {
      Node node = new Node(null, new ComponentMock(), ({props, children}) => null);
      expect(node.listeners, equals(null));

      node.apply(listeners: {});

      expect(node.listeners, equals({}));

    });

  });

}
