part of tiles;

class Node {
  final Component component;
  
  List<NodeChild> children;
  
  final Node parent;
  
  bool _isDirty = false;
  
  bool _hasDirtyDescendant = false;
  
  dynamic _oldProps;
  
  bool get isDirty => _isDirty;
  
  bool get hasDirtyDescendant => _hasDirtyDescendant;
  
  void componentNeedUpdate(bool now) {
    this.isDirty = true;
  }
  
  /**
   * mark this instance as dirty and if status was changed, 
   * than flag whole route to root of node tree as "has dirty descendant".
   */
  void set isDirty(bool value) {
    if (value) {
      bool changed = !_isDirty;
      this._isDirty = true;
      if (parent != null && changed && !_hasDirtyDescendant) {
        parent.hasDirtyDescendant = true;

      }
    }
  }
  
  /**
   * set only if it is true and set it true too to whole parent path 
   */
  void set hasDirtyDescendant(bool value) {
    if (value) {
      bool changed = !_hasDirtyDescendant;
      _hasDirtyDescendant = true;
      if (parent != null && changed) {
        parent.hasDirtyDescendant = true;
      }
    }
  }

  /**
   * Create node with component from it's description
   * 
   *   Node node = new Node(parent, description); 
   */
  Node(this.parent, Component this.component) {
    this.isDirty = true;
    this.children = [];
    if (component.needUpdate != null) {
      component.needUpdate.listen(componentNeedUpdate);
    }
  }
  
//  Node(...)

  /**
   * Recognize if update this instance or children by _isDirty and _hasDirtyDescendants
   */
  List<NodeChange> update([bool addOwnUpdate = true]) {
    /**
     * if nothing in this subtree is changed, return empty list
     */
    if (!_isDirty && !_hasDirtyDescendant) {
      return [];
    }
    
    /**
     * else create list and 
     */
    List<NodeChange> result = [];

    /**
     * if node is dirty, add everything returned by _updateThis, 
     */
    if (_isDirty) {
      result.addAll(_updateThis(addOwnUpdate));
    }

    /**
     * and in every case, add everything from children.
     */
    children.forEach((child) => result.addAll(child.node.update()));

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
  List<NodeChange> _updateThis([bool addOwnUpdate = true]) {
    List<NodeChange> result = []; 
    /**
     * create result as list with this as updated.
     */
    if (addOwnUpdate) {
      result = [new NodeChange(NodeChangeType.UPDATED, this, _oldProps, this.component.props)];
    }
    
    /**
     * update children and add node changes to result
     */
    result.addAll(_updateChildren(this));

    
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
  void apply([dynamic props, List<ComponentDescription> children]) {
    this.component.willReceiveProps(props);
    this._oldProps = this.component.props;
    this.component.props = props;
    this.component.children = children;
    this.isDirty = true;
  }
  
}

class NodeChild {
  final Node node; 
  final ComponentFactory factory;
  final dynamic key;
  
  NodeChild(this.node, this.factory, [this.key]);
}
