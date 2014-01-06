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
  
  bool get isDirty => _isDirty;
  
  bool get hasDirtyDescendant => _hasDirtyDescendant;
  
  /**
   * mark this instance as dirty and if status was changed, 
   * than flag whole route to root of node tree as "has dirty descendant".
   */
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

  /**
   * Create node with component from it's description
   * 
   *   Node node = new Node(parent, description); 
   */
  Node(this._parent, ComponentDescriptionInterface description) : _factory = description.factory {
    this._component = description.createComponent(this);
    this.isDirty = true;
    this._children = [];
  }

  /**
   * Recognize if update this instance or children by _isDirty and _hasDirtyDescendants
   */
  List<NodeChangeInterface> update(){
    /**
     * if nothing in this subtree is changed, return empty list
     */
    if(!_isDirty && !_hasDirtyDescendant){
      return [];
    }
    
    /**
     * else create list and 
     */
    List<NodeChangeInterface> result = [];

    /**
     * if node is dirty, add everything returned by _updateThis, 
     */
    if(_isDirty){
      result.addAll(_updateThis());
    }

    /**
     * and in every case, add everything from children.
     */
    _children.forEach((child) => result.addAll(child.update()));

    /**
     * tag this node as clean without dirty descendants
     */
    this._isDirty = this._hasDirtyDescendant = false;
    
    /**
     * return counted list of changes in tree.
     */
    return result;
  }
  
  /**
   * Get component descriptions from this._component render method, 
   * compare them with children, and 
   * update children to corespond with component descriptions.
   * 
   * For now, don't recognize keys. TODO
   * 
   * Returns changes on children 
   */
  List<NodeChangeInterface> _updateThis(){
    /**
     * create result as list with this as updated.
     */
    List<NodeChangeInterface> result = [new NodeChange(NodeChangeType.UPDATED, this)];

    /**
     * get components descriptions from this.component.render
     */
    List<ComponentDescriptionInterface> newChildren = this.component.render();
    
    /** 
     * if component don't render anything and return null instead of empty list,
     * replace null with empty list. 
     */
    if(newChildren == null){
      newChildren = [];
    }
    
    /**
     * for all children which are in both, children and newChildren, 
     * update ( or replace ) it
     */
    for(int i = 0; i < children.length && i < newChildren.length; ++i) {
      /** 
       * if factory is same, update child, else replace child 
       */
      if(children[i].factory == newChildren[i].factory) {
        children[i].apply(newChildren[i]);
      } else {
        NodeInterface oldChild = children[i];
        children[i] = new Node(this, newChildren[i]);
        result.add(new NodeChange(NodeChangeType.DELETED, oldChild));
        result.add(new NodeChange(NodeChangeType.CREATED, children[i]));
      }
      /** 
       * add child.update() changes to result 
       */
      result.addAll(children[i].update());
    }

    /**
     * if new children is more then old, add new children at the end,
     * if new children is less then old, remove old from last
     */
    if (children.length < newChildren.length) {
      for(int i = children.length; i < newChildren.length; ++i){
        Node child = new Node(this,  newChildren[i]);
        children.add(child);
        result.add(new NodeChange(NodeChangeType.CREATED, child));
        result.addAll(child.update());
      }
    } else if(children.length > newChildren.length){
      for(int i = 0; i < children.length - newChildren.length; ++i){
        NodeInterface removed = children.removeLast();
        result.add(new NodeChange(NodeChangeType.DELETED, removed));
      }
    }
    
    /**
     * return counted change-list
     */
    return result;
  }
  
  /**
   * apply propagate props from description to inner component. 
   */
  void apply(ComponentDescriptionInterface description){
    if(description.factory != this._factory){
      throw new DifferentFactoryException();
    }

    this.component.willReceiveProps(description.props);
    this.component.props = description.props;
    this.isDirty = true;
  }
  
}