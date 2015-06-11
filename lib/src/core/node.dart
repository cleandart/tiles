part of tiles;

class Node {
  final Component component;

  List<Node> children;

  final Node parent;

  final dynamic key;

  final ComponentFactory factory;

  Map listeners;

  bool _isDirty = false;

  bool _hasDirtyDescendant = false;

  dynamic _oldProps;

  bool _wasNeverUpdated = true;

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
      logger.fine("Node set dirty to true");
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
      logger.fine("Node set has dirty descendant to true");
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
  Node(this.parent, Component this.component, this.factory,
      {this.key, this.listeners}) {
    this.isDirty = true;
    this.children = [];
    if (component.needUpdate != null) {
      component.needUpdate.listen(componentNeedUpdate);
    }
  }

  factory Node.fromDescription(Node parent, ComponentDescription description) {
    return new Node(parent, description.createComponent(), description.factory,
        key: description.key, listeners: description.listeners);
  }

  /**
   * Recognize if update this instance or children by _isDirty and _hasDirtyDescendants
   */
  update({List<NodeChange> changes, bool force: false, Map oldListeners}) {
    logger.fine("Node.update");
    if (_wasNeverUpdated ||
        ((_isDirty || force) &&
            (component.shouldUpdate(component.props, _oldProps)) != false)) {
      logger.finer(
          'need update: dirty = $isDirty, force = $force, _wasNeverUpdated = $_wasNeverUpdated');

      /**
       * create result as list with this as updated.
       */
      _addChanges(new NodeChange(NodeChangeType.UPDATED, this,
          oldProps: _oldProps,
          newProps: this.component.props,
          oldListeners: oldListeners,
          newListeners: listeners), changes);

      /**
       * update children and add node changes to result
       */
      _updateChildren(this, changes: changes);

      this._wasNeverUpdated = this._isDirty = this._hasDirtyDescendant = false;
    } else if (_hasDirtyDescendant) {
      logger.finer('has dirty desc');
      /**
       * if has dirty descendant, call update recursively and set self as don't have dirty descendant.
       */
      children.forEach((child) => child.update(changes: changes));

      this._hasDirtyDescendant = false;
    } else {
      logger.finer('going to update nothing');
    }
  }

  /**
   * apply props to inner component.
   *
   * if no props, apply null
   */
  void apply(
      {dynamic props, List<ComponentDescription> children, Map listeners}) {
    logger.fine("Node.apply");
    this.component.willReceiveProps(props);
    this._oldProps = this.component.props;
    this.component.props = props;
    this.component.children = children;
    this.listeners = listeners;
  }
}

/**
 * helper function, to enable not everywhere to add the same if
 */
_addChanges(NodeChange change, List<NodeChange> changes) {
  if (changes != null) {
    changes.add(change);
  }
}
