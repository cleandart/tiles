part of tiles_browser;

/**
 * Performs update of dom.
 * 
 * Find all root nodes, and updte each tree by updating root node.
 */
_update(dynamic data) {
  List<Node> rootNodes = [];
  _nodeToElement.keys.forEach((Node node) {
    if (node.parent == null) {
      rootNodes.add(node);
    }
  });
  rootNodes.forEach((Node node) {
    _updateTree(node);
  });
}

/**
 * Perform update for node tree starting from root node.
 * 
 * Performs update on root node and apply this changes to dom.  
 */
_updateTree(Node rootNode) {
  if (rootNode.isDirty || rootNode.hasDirtyDescendant) {
    List<NodeChange> changes = rootNode.update();
    changes.forEach((NodeChange change) => _applyChange(change));
  }
}

/**
 * Apply one change to the dom.
 * 
 * Distinguish type of change and call adequate method
 */
_applyChange(NodeChange change) {
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
      break;
  }
}

/**
 * Apply change with type NodeChange.CREATED 
 * and place node from change to correct place in DOM
 */
_applyCreatedChange(NodeChange change) {
  Node node = change.node;
  html.Element mountRoot = _nodeToElement[node.parent];
  Node nextNode = _findFirstDomDescendantAfter(node.parent, node);
  _mountNode(node, mountRoot, false, nextNode);
}

/**
 * Finds first descendant of parent after node 
 * which is dom component allready rendered in DOM
 */
_findFirstDomDescendantAfter(Node parent, Node node) {
  Node result;
  for(int i = parent.children.length - 1; i >= 0; --i) {
    Node child = parent.children[i];
    if (child == node) {
      break;
    }
    if (child.component is DomComponent && _nodeToElement[child] != null) {
      result = child;
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
  if (change.node.component is DomComponent) {
    html.Element element = _nodeToElement[change.node];
    Map oldProps = change.oldProps;
    Map newProps = change.newProps;
    
    /**
     * change or remove old attributes
     */
    if (oldProps != null) {
      oldProps.forEach((String key, dynamic value) {
        if (newProps == null) {
          return;
        }
        
        if (!newProps.containsKey(key)) {
          element.attributes.remove(key);
        } else if (newProps[key] != value) {
          element.setAttribute(key, newProps[key].toString());
        }
      });
    }
    
    /**
     * add new attributes
     */
    if (newProps != null) {
      newProps.forEach((String key, dynamic value) {
        if (oldProps == null || !oldProps.containsKey(key)) {
          element.setAttribute(key, value.toString());
        }
      });
    }
  }
}

/** 
 * Applies delete change by removing node from DOM. 
 */
_applyDeletedChange(NodeChange change) {
  _removeNodeFromDom(change.node);
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
  if (node.component is DomComponent) {
    html.Element element = _nodeToElement[node];
    element.remove();
  } else {
    for (Node child in node.children) {
      _removeNodeFromDom(child);
    }
  }
}

