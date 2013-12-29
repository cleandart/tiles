part of library;

class Node implements NodeInterface {
  ComponentInterface _component;
  
  final ComponentFactory _factory;
  
  List<NodeInterface> _children;
  
  final NodeInterface _parent;
  
  bool _isDirty = false;
  
  bool _hasDirtyDescendant = false;
  
  ComponentInterface get component => _component;
  
  ComponentFactory get factory => _factory;
  
  List<NodeInterface> get children => _children;

  NodeInterface get parent => _parent;
  
  void set isDirty(bool value){
    if(value){
      bool changed = !_isDirty;
      this._isDirty = true;
      if(_parent != null && changed && !_hasDirtyDescendant){
        _parent.hasDirtyDescendant = true;
      }
    }
  }
  
  /**
   * set only if it is true and set it true too to whole parent path 
   */
  void set hasDirtyDescendant(bool value){
    if(value){
      bool changed = !_hasDirtyDescendant;
      _hasDirtyDescendant = true;
      if(_parent != null && changed){
        _parent.hasDirtyDescendant = true;
      }
    }
  }

  Node(this._parent, ComponentDescriptionInterface description) : _factory = description.factory {
    this._component = description.createComponent(this);
  }

  /**
   * Recognize if update this instance or childrens by _isDirty and _hasDirtyDescendants
   */
  List<NodeChangeInterface> update(){
    
  }
  
  /**
   * Get component descriptions from this._component render method, 
   * compare them with children, and 
   * update children to corespond with component descriptions.
   * 
   * Returns changes on children 
   */
  List<NodeChangeInterface> _updateThis(){
    
  }
  
  apply(ComponentDescriptionInterface componentDescription){
    
  }
  
}