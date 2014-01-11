part of library;

class Node {
  final Component _component;
  
  List<_NodeWithFactory> _children;
  
  final Node _parent;
  
  bool _isDirty = false;
  
  bool _hasDirtyDescendant = false;
  
  Props _oldProps;
  
  Component get component => _component;
  
  List<Node> get children {
    List<Node> children = new List<Node>();
    _children.forEach((childWithFactory) => children.add(childWithFactory.node));
    return children;
  }
  
  List<_NodeWithFactory> get rawChildren => _children;

  Node get parent => _parent;
  
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
  Node(this._parent, Component this._component){
    this.isDirty = true;
    this._children = [];
  }
  
//  Node(...)

  /**
   * Recognize if update this instance or children by _isDirty and _hasDirtyDescendants
   */
  List<NodeChange> update(){
    /**
     * if nothing in this subtree is changed, return empty list
     */
    if(!_isDirty && !_hasDirtyDescendant){
      return [];
    }
    
    /**
     * else create list and 
     */
    List<NodeChange> result = [];

    /**
     * if node is dirty, add everything returned by _updateThis, 
     */
    if(_isDirty){
      result.addAll(_updateThis());
    }

    /**
     * and in every case, add everything from children.
     */
    children.forEach((child) => result.addAll(child.update()));

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
  List<NodeChange> _updateThis(){
    /**
     * create result as list with this as updated.
     */
    List<NodeChange> result = [new NodeChange(NodeChangeType.UPDATED, this, _oldProps, this.component.props)];

    /**
     * get components descriptions from this.component.render
     */
    List<ComponentDescription> newChildren = this.component.render();
    
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
      if(_children[i].factory == newChildren[i].factory) {
        children[i].apply(newChildren[i].props);
      } else {
        Node oldChild = children[i];
        _children[i] = new _NodeWithFactory(new Node(this, newChildren[i].createComponent()), newChildren[i].factory);
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
        _NodeWithFactory child = new _NodeWithFactory(new Node(this,  newChildren[i].createComponent()), newChildren[i].factory);
        _children.add(child);
        result.add(new NodeChange(NodeChangeType.CREATED, child.node));
        result.addAll(child.node.update());
      }
    } else if(children.length > newChildren.length){
      for(int i = 0; i < children.length - newChildren.length; ++i){
        _NodeWithFactory removed = _children.removeLast();
        result.add(new NodeChange(NodeChangeType.DELETED, removed.node));
      }
    }
    
    /**
     * return counted change-list
     */
    return result;
  }
  
  /**
   * apply props to inner component.
   * 
   * if no props, apply null
   */
  void apply([Props props]){
    this.component.willReceiveProps(props);
    this._oldProps = this.component.props;
    this.component.props = props;
    this.isDirty = true;
  }
  
}

class _NodeWithFactory {
  final Node node; 
  final ComponentFactory factory;
  
  _NodeWithFactory(this.node, this.factory);
}

