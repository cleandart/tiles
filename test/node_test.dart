import 'package:unittest/unittest.dart';
//import 'package:unittest/mock.dart';
import 'package:library/library.dart';


//class ComponentMock extends Mock implements Component {}

main() {
  
//  var component = new ComponentMock()
//    ..when(callsTo('render')).alwaysReturn([]);
//  
//  component.getLogs(callsTo('componentWillReceiveProps')).verify(happenedOnce);
  group("(Node)", () {

    /**
     * prepare default factory and component description
     */
    ComponentFactory factory = ([Node node, Props props]) => new MockComponent(node, props);
    ComponentDescription description = new MockComponentDescription(factory, null);
    
    /**
     * prepare more complex factory and descriptions, which work with another component class
     */
    ComponentFactory complexFactory = ([Node node, Props props]) => new RenderingMockComponent(node, props);
    ComponentDescription complexDescription = new MockComponentDescription(complexFactory, null);

    /**
     * test simple constructor and state after constructor was called
     */
    test("constructor", () {
      
      Node node = new Node(null, description.createComponent());
      expect(node.component.props, equals(null));
      expect(node.isDirty, equals(true));
      expect(node.hasDirtyDescendant, equals(false));
      expect(node.component is MockComponent, equals(true));
      expect(node.children, isEmpty);
    });
    
    /**
     * test if constructor set parent path as has dirty descendant
     */
    test("constructor - as child, parent has dirty descendant", () {
      Node node = new Node(null, description.createComponent());
      Node node2 = new Node(node, description.createComponent());
      
      expect(node.hasDirtyDescendant, equals(true));
    });
    
    /**
     * test simple update, with no children
     */
    test("update - isDirty is false after update", () {
      Node node = new Node(null, description.createComponent());
      expect(node.isDirty, equals(true));
      
      node.update();
      expect(node.isDirty, equals(false));
      
      /**
       * create new node as child of our node.
       */
    });
    
    /**
     * test node with component, which render always return description with same factory.
     */
    test("update - more complex", () {
      Node node = new Node(null, complexDescription.createComponent());
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
      
      node.apply(complexDescription.props);
      
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
      ComponentFactory rf = ([Node node, Props props]) => 
          new RenderingAlwaysNewFactoryComponent(node, props);
      ComponentDescription rd = new MockComponentDescription(rf, null);
      
      Node node = new Node(null, rd.createComponent());
      node.update();
      
      /**
       * node have some child
       */
      expect(node.children.isNotEmpty, isTrue);
      
      /**
       * save first child to oldChild
       */
      Node oldChild = node.children.first;
      
      node.apply(rd.props);
      node.update();
      /**
       * because in RenderingAlwaysNewFactoryComponent is always created new, 
       * unique factory, node.update always replace child.
       */
      expect(node.children.first, isNot(oldChild));
    });
    
  });
}

class MockComponent implements Component {
  
  Props get props => null;
  
  void set props(Props newProps){}

  get needUpdate => null;

  willReceiveProps(Props newProps){}
  
  shouldUpdate(Props newProps, Props oldProps){}
  
  didMount(){}
  
  didUpdate(){}
  
  willUnmount(){}
  
  List<ComponentDescription> render(){}
  
  MockComponent(Node this.node, Props this._props){}
  
  Node node;
  
  Props _props;

}

class MockComponentDescription implements ComponentDescription {
  ComponentFactory get factory => _factory;
  ComponentFactory _factory;
  
  Props get props => _props;
  Props _props;
  
  MockComponentDescription (ComponentFactory this._factory, Props  this._props);
  
  Component createComponent([Node node]) => factory(node, props);
}

class RenderingMockComponent implements Component {
  
  Props get props => null;
  
  void set props(Props newProps){}

  get needUpdate => null;

  willReceiveProps(Props newProps){}
  
  shouldUpdate(Props newProps, Props oldProps){}
  
  didMount(){}
  
  didUpdate(){}
  
  willUnmount(){}
  
  List<ComponentDescription> render(){
    return [new MockComponentDescription(componentFactory, null)];
  }
  
  RenderingMockComponent(Node this.node, Props this._props){}
  
  Node node;
  
  Props _props;

}

ComponentFactory componentFactory = ([Node node, Props props]) => new MockComponent(node, props);

class RenderingAlwaysNewFactoryComponent implements Component {
  
  Props get props => null;
  
  void set props(Props newProps){}

  get needUpdate => null;

  willReceiveProps(Props newProps){}
  
  shouldUpdate(Props newProps, Props oldProps){}
  
  didMount(){}
  
  didUpdate(){}
  
  willUnmount(){}
  
  List<ComponentDescription> render(){
    return [new MockComponentDescription(([Node node, Props props]) => new MockComponent(node, props), null)];
  }
  
  RenderingAlwaysNewFactoryComponent (Node this.node, Props this._props);
  
  Node node;
  
  Props _props;

}

