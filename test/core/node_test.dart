library tiles_node_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles.dart';
import '../mocks.dart';


main() {
  
//  var component = new ComponentMock()
//    ..when(callsTo('render')).alwaysReturn([]);
//  
//  component.getLogs(callsTo('componentWillReceiveProps')).verify(happenedOnce);
  group("(Node)", () {

    /**
     * test simple constructor and state after constructor was called
     */
    test("constructor", () {
      Node node = new Node(null, new ComponentMock());
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
      Node node = new Node(null, new ComponentMock());
      Node node2 = new Node(node, new ComponentMock());
      
      expect(node.hasDirtyDescendant, equals(true));
    });
    
    /**
     * test simple update, with no children
     */
    test("update - check isDirty before and after", () {
      Node node = new Node(null, new ComponentMock());
      expect(node.isDirty, equals(true));
      
      node.update();
      expect(node.isDirty, equals(false));
      
    });
    
    /**
     * test node with component, which render always return description with same factory.
     */
    test("update - component will return description of one component, node should have one child", () {
      ComponentDescriptionMock description = new ComponentDescriptionMock();

      description.when(callsTo("createComponent")).alwaysReturn(new ComponentMock());
      description.when(callsTo("get factory")).alwaysReturn(([dynamic props, children]) => new ComponentMock());
      
      ComponentMock component = new ComponentMock();

      component.when(callsTo("render")).alwaysReturn([description]);
      
      Node node = new Node(null, component);
      var changes = node.update();
      
      /**
       * test if changes are as they should be - updated, created child and updated child.
       */
      expect(changes.length, equals(3));
      expect(changes.first.type, equals(NodeChangeType.UPDATED));
      expect(changes.first.node, equals(node));
      expect(changes[1].type, equals(NodeChangeType.CREATED));
      expect(changes[1].node, isNot(node));
      expect(changes.last.type, equals(NodeChangeType.UPDATED));
      expect(changes.last.node, equals(changes[1].node));
      
      /**
       * try, if node has children as they should
       */
      expect(node.children.isNotEmpty, isTrue);
      expect(node.children.length, equals(1));
      
      /**
       * and then try another update
       * as node is not dirty, and don't have dirty descendatns, 
       * no change is generated 
       */
    });
    
    test("update - if no apply called, update will do no change", () {
      ComponentDescriptionMock description = new ComponentDescriptionMock();

      description.when(callsTo("createComponent")).alwaysReturn(new ComponentMock());
      description.when(callsTo("get factory")).alwaysReturn(([dynamic props, children]) => new ComponentMock());
      
      ComponentMock component = new ComponentMock();

      component.when(callsTo("render")).alwaysReturn([description]);
      
      Node node = new Node(null, component);
      node.update();
      
      var changes = node.update();
      expect(changes, isEmpty);
      
    });
    
    test("update - node with dirty child, update will return only change of updated child", () {
      ComponentDescriptionMock description = new ComponentDescriptionMock();

      description.when(callsTo("createComponent")).alwaysReturn(new ComponentMock());
      description.when(callsTo("get factory")).alwaysReturn(([dynamic props, children]) => new ComponentMock());
      
      ComponentMock component = new ComponentMock();

      component.when(callsTo("render")).alwaysReturn([description]);
      
      Node node = new Node(null, component);
      node.update();
      
      node.children.first.isDirty = true;
      
      expect(node.hasDirtyDescendant, isTrue);
      
      var changes = node.update();

      expect(node.hasDirtyDescendant, isFalse);
      
      expect(changes.isEmpty, isFalse);
      expect(changes.length, equals(1));
      expect(changes.first.node, equals(node.children.first));
      expect(changes.first.type, equals(NodeChangeType.UPDATED));

    });
    
    test("update - if factory is the same, child will be the same", () {
      ComponentDescriptionMock description = new ComponentDescriptionMock();

      description.when(callsTo("createComponent")).alwaysReturn(new ComponentMock());
      description.when(callsTo("get factory")).alwaysReturn(([dynamic props, children]) => new ComponentMock());
      
      ComponentMock component = new ComponentMock();

      component.when(callsTo("render")).alwaysReturn([description]);
      
      Node node = new Node(null, component);
      node.update();
      
      Node oldNode = node.children.first;
      
      node.apply();
      
      var changes = node.update();
      expect(changes.isEmpty, isFalse);
      expect(changes.length, equals(2)); // both, node and it's child is updated
      
      expect(node.children.first, equals(oldNode));
      
    });
    
    test("update - when factory is different, child will be replaced", () {
      
      ComponentDescriptionMock description = new ComponentDescriptionMock();

      description.when(callsTo("createComponent")).alwaysReturn(new ComponentMock());
      
      /**
       * return every time new factory
       */
      description.when(callsTo("get factory"))
        .thenReturn(([dynamic props, children]) => new ComponentMock())
        .thenReturn(([dynamic props, children]) => new ComponentMock())
        .thenReturn(([dynamic props, children]) => new ComponentMock());
      
      ComponentMock component = new ComponentMock();

      component.when(callsTo("render")).alwaysReturn([description]);
      

      Node node = new Node(null, component);
      node.update();
      
      /**
       * node have some child
       */
      expect(node.children.isNotEmpty, isTrue);
      
      /**
       * save first child to oldChild
       */
      Node oldChild = node.children.first;
      
      node.apply();

      node.update();
      /**
       * because in RenderingAlwaysNewFactoryComponent is always created new, 
       * unique factory, node.update always replace child.
       */
      expect(node.children.first, isNot(oldChild));
    });
    
  });
}
