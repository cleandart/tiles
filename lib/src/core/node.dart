part of tiles;

class Node {
  final Component component;

  List<NodeWithFactory> children;

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
      bool oldHasDirty = _hasDirtyDescendant;
      _hasDirtyDescendant = true;
      if (parent != null && !oldHasDirty) {
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
  List<NodeChange> update() {
    print('update ${this.component}');
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
      result.addAll(_updateThis());
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

    print('result: ${result}');

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
  List<NodeChange> _updateThis() {
    print('_updateThis ${this.component}');

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
    if (newChildren == null) {
      newChildren = [];
    }

    /**
     * for all children which are in both, children and newChildren,
     * update (or replace) it
     */
    for(int i = 0; i < children.length && i < newChildren.length; ++i) {
      /**
       * if factory is same, update child, else replace child
       */
      if (children[i].factory == newChildren[i].factory) {
//        if (children[i].node.component is! DomTextComponent) {
//
//        }
//        print('the same: ${children[i].node.component}');
        print('apply on children');
        children[i].node.apply(newChildren[i].props, newChildren[i].children);
      } else {
        Node oldChild = children[i].node;
        children[i] = new NodeWithFactory(new Node(this, newChildren[i].createComponent()), newChildren[i].factory);
        result.add(new NodeChange(NodeChangeType.DELETED, oldChild));
        result.add(new NodeChange(NodeChangeType.CREATED, children[i].node));
      }
      /**
       * add child.update() changes to result
       */
      result.addAll(children[i].node.update());
    }

    /**
     * if new children is more then old, add new children at the end,
     * if new children is less then old, remove old from last
     */
    if (children.length < newChildren.length) {
      for(int i = children.length; i < newChildren.length; ++i) {
        NodeWithFactory child = new NodeWithFactory(new Node(this,  newChildren[i].createComponent()), newChildren[i].factory);
        children.add(child);
        result.add(new NodeChange(NodeChangeType.CREATED, child.node));
        result.addAll(child.node.update());
      }
    } else if (children.length > newChildren.length) {
      for(int i = 0; i < children.length - newChildren.length; ++i) {
        NodeWithFactory removed = children.removeLast();
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
  void apply([dynamic props, List<ComponentDescription> children]) {
    this.component.willReceiveProps(props);
    this._oldProps = this.component.props;
    this.component.props = props;
    this.component.children = children;
    this.isDirty = true;
  }

}

class NodeWithFactory {
  final Node node;
  final ComponentFactory factory;

  NodeWithFactory(this.node, this.factory);
}
