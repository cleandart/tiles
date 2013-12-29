part of library;

abstract class NodeInterface {
  ComponentInterface get component;
  
  ComponentFactory get factory;
  
  List<NodeInterface> get children;

  NodeInterface get parent;
  
  void set isDirty(bool value);
  
  void set hasDirtyDescendant(bool value);

  NodeInterface(NodeInterface parent, ComponentDescriptionInterface description);

  List<NodeChangeInterface> update();
  
  List<NodeChangeInterface> _updateThis();
  
  apply(ComponentDescriptionInterface componentDescription);  
}
