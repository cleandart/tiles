import 'package:unittest/unittest.dart';
//import 'package:unittest/mock.dart';
import 'package:library/library.dart';

main() {
  group("(Node)", () {

    /**
     * prepare default factory and component description
     */
    ComponentFactory factory = ([NodeInterface node, PropsInterface props]) => new MockComponent(node, props);
    ComponentDescriptionInterface description = new MockComponentDescription(factory, null);
    
    /**
     * prepare more complex factory and descriptions, which work with another component class
     */
    ComponentFactory complexFactory = ([NodeInterface node, PropsInterface props]) => new RenderingMockComponent(node, props);
    ComponentDescriptionInterface complexDescription = new MockComponentDescription(complexFactory, null);

    /**
     * test simple constructor and state after constructor was called
     */
    test("constructor", () {
      
      Node node = new Node(null, description);
      expect(node.factory, equals(factory));
      expect(node.component.props, equals(null));
      expect(node.isDirty, equals(true));
      expect(node.hasDirtyDescendant, equals(false));
      expect(node.component is MockComponent, equals(true));
      expect(node.children, isEmpty);
    });
    
    /**
     * test if constructor set parent path as has dirty descendant
     */
    test("constructor - as child", () {
      Node node = new Node(null, description);
      Node node2 = new Node(node, description);
      
      expect(node.hasDirtyDescendant, equals(true));
    });
    
    /**
     * test simple update, with no children
     */
    test("update - simple", () {
      Node node = new Node(null, description);
      expect(node.isDirty, equals(true));
      
      node.update();
      expect(node.isDirty, equals(false));
      
      /**
       * create new node as child of our node.
       */
      Node child = new Node(node, description);
      node.children.add(child);
      
      node.apply(description);
      var changes = node.update();
      
      expect(changes.length, equals(2));
      /**
       * first part is that node is updated
       */
      expect(changes.first.type, equals(NodeChangeType.UPDATED));
      expect(changes.first.node, equals(node));
      /**
       * as node.component.render() return null, node recognize, it has no child som it remove all it actual children.
       */
      expect(changes.last.type, equals(NodeChangeType.DELETED));
      expect(changes.last.node, equals(child));
      
      /**
       * as node was updated, it should be clean (not dirty) and nave no dirty descendants. 
       */
      expect(node.isDirty, equals(false));
      expect(node.hasDirtyDescendant, equals(false));
      
      /**
       * as child was just removed, is was untouched, so it's dirty state was not changed
       */
      expect(child.isDirty, equals(true));
    });
    
    /**
     * test node with component, which render always return description with same factory.
     */
    test("update - more complex", () {
      Node node = new Node(null, complexDescription);
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
      expect(node.children.first.factory, equals(componentFactory));
      
      /**
       * and then try another update
       * as node is not dirty, and don't have dirty descendatns, 
       * no change is generated 
       */
      changes = node.update();
      expect(changes, isEmpty);
      
      /**
       * try scenario, that child was somehow "updated"
       */
      node.children.first.isDirty = true;
      
      expect(node.hasDirtyDescendant, isTrue);
      
      changes = node.update();

      expect(node.hasDirtyDescendant, isFalse);
      
      expect(changes.isEmpty, isFalse);
      expect(changes.length, equals(1));
      expect(changes.first.node, equals(node.children.first));

      /**
       * and try, if after updated of node is not generated new child, 
       * but only existing is updated
       */
      Node oldNode = node.children.first;
      
      node.apply(complexDescription);
      
      changes = node.update();
      expect(changes.isEmpty, isFalse);
      expect(changes.length, equals(2)); // both, node and it's child is updated
      
      /**
       * as RenderingMockComponent return always description with the same factory, 
       * child is only updated, not replaced
       */
      expect(node.children.first, equals(oldNode));
      
    });
    
    test("update - always replacing children", () {
      /**
       * new factory of "rendering always new" component.
       */
      ComponentFactory rf = ([NodeInterface node, PropsInterface props]) => 
          new RenderingAlwaysNewFactoryComponent(node, props);
      ComponentDescriptionInterface rd = new MockComponentDescription(rf, null);
      
      Node node = new Node(null, rd);
      node.update();
      
      /**
       * node have some child
       */
      expect(node.children.isNotEmpty, isTrue);
      
      /**
       * save first child to oldChild
       */
      Node oldChild = node.children.first;
      
      node.apply(rd);
      node.update();
      /**
       * because in RenderingAlwaysNewFactoryComponent is always created new, 
       * unique factory, node.update always replace child.
       */
      expect(node.children.first, isNot(oldChild));
    });
    
    test("apply - wrong factory", (){
      Node node = new Node(null, complexDescription);

      /**
       * try to apply description with different factory and test, 
       * if it throws DifferentFactoryException
       */
      expect(() => node.apply(description), throwsA(new isInstanceOf<DifferentFactoryException>()));
      
    });

    
//    test("constructor")
    
  });
}

class MockComponent implements ComponentInterface {
  
  PropsInterface get props => null;
  
  void set props(PropsInterface newProps){}

  willReceiveProps(PropsInterface newProps){}
  
  shouldUpdate(PropsInterface newProps, PropsInterface oldProps){}
  
  didMount(){}
  
  didUpdate(){}
  
  willUnmount(){}
  
  List<ComponentDescriptionInterface> render(){}
  
  MockComponent(NodeInterface this.node, PropsInterface this._props){}
  
  NodeInterface node;
  
  PropsInterface _props;

}

class MockComponentDescription implements ComponentDescriptionInterface {
  ComponentFactory get factory => _factory;
  ComponentFactory _factory;
  
  PropsInterface get props => _props;
  PropsInterface _props;
  
  MockComponentDescription (ComponentFactory this._factory, PropsInterface  this._props);
  
  ComponentInterface createComponent([NodeInterface node]) => factory(node, props);
}

class RenderingMockComponent implements ComponentInterface {
  
  PropsInterface get props => null;
  
  void set props(PropsInterface newProps){}

  willReceiveProps(PropsInterface newProps){}
  
  shouldUpdate(PropsInterface newProps, PropsInterface oldProps){}
  
  didMount(){}
  
  didUpdate(){}
  
  willUnmount(){}
  
  List<ComponentDescriptionInterface> render(){
    return [new MockComponentDescription(componentFactory, null)];
  }
  
  RenderingMockComponent(NodeInterface this.node, PropsInterface this._props){}
  
  NodeInterface node;
  
  PropsInterface _props;

}

ComponentFactory componentFactory = ([NodeInterface node, PropsInterface props]) => new MockComponent(node, props);

class RenderingAlwaysNewFactoryComponent implements ComponentInterface {
  
  PropsInterface get props => null;
  
  void set props(PropsInterface newProps){}

  willReceiveProps(PropsInterface newProps){}
  
  shouldUpdate(PropsInterface newProps, PropsInterface oldProps){}
  
  didMount(){}
  
  didUpdate(){}
  
  willUnmount(){}
  
  List<ComponentDescriptionInterface> render(){
    return [new MockComponentDescription(([NodeInterface node, PropsInterface props]) => new MockComponent(node, props), null)];
  }
  
  RenderingAlwaysNewFactoryComponent (NodeInterface this.node, PropsInterface this._props);
  
  NodeInterface node;
  
  PropsInterface _props;

}

