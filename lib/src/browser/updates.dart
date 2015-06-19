part of tiles_browser;

/**
 * Flag that browser configuration was initialized,
 *
 * to libraty by able to throw exception
 * on duplicated initialization of browser configuration.
 */
bool _browserConfigurationInitialized = false;

/**
 * Init browser configuration to proper function of library.
 *
 * It initialize request anmimation frame loop,
 * which controlls root nodes if don't have dirty descendats.
 */
initTilesBrowserConfiguration() {
  logger.fine("initTilesBrowserConfiguration called");

  if (!_browserConfigurationInitialized) {
    html.window.animationFrame.then(_update);
    _browserConfigurationInitialized = true;
  } else {
    logger.finer("initialized second not first time");

    throw "Browser configuration should not be initialized twice";
  }

}

/**
 * Performs update of dom.
 *
 * Find all root nodes, and updte each tree by updating root node.
 * At the end, request new animation frame
 */
_update(num data) {
  logger.finer("_update called");
  try {
    _updateTrees();
  } finally {
    html.window.animationFrame.then(_update);
  }
}

/**
 * Performs update of dom synchronously.
 *
 * Find all root nodes, and updte each tree by updating root node.
 */
_updateTrees() {
  _rootNodes.forEach((Node node) {
    _updateTree(node);
  });
}

/**
 * Function to sync update of all doms - for benchmarks.
 */
updateAllVirtualDomTreesSync() {
  _updateTrees();
}

/**
 * Perform update for node tree starting from root node.
 *
 * Performs update on root node and apply this changes to dom.
 */
_updateTree(Node rootNode) {
  logger.finer("_updateTree called");
  if (rootNode.isDirty || rootNode.hasDirtyDescendant) {
    logger.finer("updating dirty tree");
    List<NodeChange> changes = [];
    rootNode.update(changes: changes);
    changes.reversed.forEach((NodeChange change) => _applyChange(change));
  }
}

/**
 * Apply one change to the dom.
 *
 * Distinguish type of change and call adequate method
 */
_applyChange(NodeChange change) {
  logger.finer("_applyChange called with type $change.type");
  switch (change.type) {
    case NodeChangeType.CREATED:
      _applyCreatedChange(change);
      break;
    case NodeChangeType.UPDATED:
      _applyUpdatedChange(change);
      break;
    case NodeChangeType.DELETED:
      _applyDeletedChange(change);
      break;
    case NodeChangeType.MOVED:
      _applyMovedChange(change);
      break;
  }
}

/**
 * Apply change with type NodeChange.CREATED
 * and place node from change to correct place in DOM
 */
_applyCreatedChange(NodeChange change) {
  logger.finer("_applyCreatedChange called");
  Node node = change.node;
  html.Element mountRoot = _nodeToElement[node.parent];
  Node nextNode = _findFirstDomDescendantAfter(node.parent, node);
  _mountNode(node, mountRoot, nextNode: nextNode);
}

/**
 * Finds first descendant of parent after node
 * which is dom component allready rendered in DOM
 */
_findFirstDomDescendantAfter(Node parent, Node node) {
  logger.finest("_findFirstDomDescendantAfter called");
  Node result;
  for (int i = parent.children.length - 1; i >= 0; --i) {
    Node child = parent.children[i];
    if (child == node) {
      break;
    }
    if (child.component is DomComponent && _nodeToElement[child] != null) {
      result = child;
    } else if (!(child.component is DomComponent)) {
      result = _findFirstDomDescendantAfter(child, node);
    }
  }

  if (result != null) {
    return result;
  }

  if (parent.component is DomComponent) {
    return null;
  }

  if (parent.parent != null) {
    return _findFirstDomDescendantAfter(parent.parent, parent);
  }
}

/**
 * Applies changes to updated component.
 *
 * If it is DOM component, update attributes of element
 * associated to node of this component.
 */
_applyUpdatedChange(NodeChange change) {
  logger.finer("_applyUpdatedChange called");
  if (change.node.component is DomComponent) {
    html.Element element = _nodeToElement[change.node];
    Map oldProps = change.oldProps;
    Map newProps = change.newProps;
    DomComponent component = change.node.component;

    /**
     * change or remove old attributes
     */
    _applyAttributes(element, newProps, svg: component.svg, node: change.node, oldProps: oldProps, listeners: change.node.listeners);
    if(component.props.containsKey(_DANGEROUSLYSETINNERHTML)){
      _dangerouslySetInnerHTML(component, element);
    }


  } else if (change.node.component is DomTextComponent) {
    /**
     * if component is dom text componetn, update text of the element
     */
    html.Text text = _nodeToElement[change.node];
    text.text = change.node.component.props;
  }
  /**
   * call life-cycle method didUpdate
   */
  change.node.component.didUpdate();
}

/**
 * Applies delete change by removing node from DOM.
 */
_applyDeletedChange(NodeChange change) {
  logger.finer("_applyDeletedChange called");

  _removeNodeFromDom(change.node);
}

/**
 * Applies move changed by moving node on the correct position.
 */
_applyMovedChange(NodeChange change) {
  logger.finer("_applyMoveChange called");
  Node node = change.node;
  _moveNode(node);
}

/**
 * Finds place of the node in the real DOM and move it there.
 *
 * Find it's closest rendered sibling after it
 * and place self element before it.
 *
 * If it contain some custom component,
 * apply this method to it's children in reversed order.
 */
_moveNode(Node node) {
  logger.finer("_moveNode called");
  if (node.component is DomComponent) {
    html.Element mountRoot = _nodeToElement[node.parent];
    Node nextNode = _findFirstDomDescendantAfter(node.parent, node);

    html.Element element = _nodeToElement[node];
    html.Element nextElement = _nodeToElement[nextNode];
    mountRoot.insertBefore(element, nextElement);
  } else {
    node.children.reversed.forEach((Node child) => _moveNode(child));
  }
}

/**
 * Remove node from DOM
 *
 * If node not containd DomComponent,
 * remove children nodes recursively.
 *
 * If contain DomComponent, remove only this,
 * because all children of element will be deleted too.
 */
_removeNodeFromDom(Node node) {
  logger.finer("_removeNodeFromDom called");
  if (node.component is DomComponent || node.component is DomTextComponent) {
    html.Node element = _nodeToElement[node];

    /**
     * remove all relations and notify component about unmount
     */
    node.component.willUnmount();

    _deleteRelations(node, element);
    element.remove();
  } else {
    /**
     * remove all relations and notify component about unmount
     */
    node.component.willUnmount();
    for (Node child in node.children) {
      _removeNodeFromDom(child);
    }
  }
}
