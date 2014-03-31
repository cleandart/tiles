part of tiles;

_updateChildren (Node node) {
  List<NodeChange> result = [];
  
  /**
   * get old children from node, next children descriptions from component and prepare next children map 
   */
  Map<dynamic, Node> oldChildren = _createChildrenMap(node.children);
  Map<dynamic, ComponentDescription> nextChildrenDescriptions = _createChildrenDescriptionMap(_getChildrenFromComponent(node.component));
  Map<dynamic, Node> nextChildren = {};
  Map<dynamic, num> oldChildrenOrder = _createOrderMap(oldChildren);
  Map<dynamic, num> nextChildrenOrder = _createOrderMap(nextChildrenDescriptions);
  
  for (dynamic key in nextChildrenDescriptions.keys) {
    ComponentDescription description = nextChildrenDescriptions[key];
    Node oldChild = oldChildren[key];
    Node nextChild;
    num oldOrder = oldChildrenOrder[key];
    num nextOrder = nextChildrenOrder[key];
    bool justCreated = false;
    
    /**
     * if factory is same, just apply new props
     */
    if (oldChild != null && oldChild.factory == description.factory) {
      nextChild = oldChild;
      nextChild.apply(description.props, description.children);
      if (oldOrder != nextOrder) {
        result.add(new NodeChange(NodeChangeType.MOVED, nextChild));
      }
    } else {
      /**
       * else create new node and if necessery, remove old one
       */
      nextChild = new Node.fromDescription(node, description);
      result.add(new NodeChange(NodeChangeType.CREATED, nextChild));
      justCreated = true;

      if (oldChild != null) {
        result.add(new NodeChange(NodeChangeType.DELETED, oldChild));
      }
    }
    nextChildren[key] = nextChild;
    result.addAll(nextChild.update(!justCreated));
  }
  for (dynamic key in oldChildren.keys) {
    if (nextChildrenDescriptions[key] == null) {
      result.add(new NodeChange(NodeChangeType.DELETED, oldChildren[key]));
    }
  }
  
  node.children = _childrenMapToList(nextChildren);
  
  return result;

}

Map<dynamic, Node> _createChildrenMap (List<Node> nodes) {
  Map result = {};
  num index = 0;
  for (Node node in nodes) {
    if (node.key != null) {
      result[node.key] = node;
    } else {
      result[index] = node;
    }
    index++;
  }
  return result;
}

Map<dynamic, ComponentDescription> _createChildrenDescriptionMap (List<ComponentDescription> descriptions) {
  Map result = {};
  num index = 0;
  for (ComponentDescription description in descriptions) {
    if (description.key != null) {
      result[description.key] = description;
    } else {
      result[index] = description;
    }
    index++;
  }
  return result;
}

Map<dynamic, num> _createOrderMap(Map map) {
  Map result = {};
  num index = 0;
  for (dynamic key in map.keys) {
      result[key] = index++;
  }
  return result;
}

List<Node> _childrenMapToList(Map<num, Node> nextChildren) {
  List<Node> result = [];
  for (Node value in nextChildren.values) {
    result.add(value);
  }
  return result;
}

List<ComponentDescription> _getChildrenFromComponent(Component component) {
  List<ComponentDescription> children;
  var rawChildren = component.render();
  if (rawChildren is ComponentDescription) {
    /**
     * if render returns componentDescription, construct newChildren list
     */
    children = [rawChildren];
  } else if (rawChildren is List<ComponentDescription>) {
    /**
     * if render returns List<componentDescription> set newChildren to it
     */
    children = rawChildren;
  } else if (children == null) {
    /** 
     * if component don't render anything and return null instead of empty list,
     * replace null with empty list. 
     */
    children = [];
  } else {
    /**
     * if it returns something else, throw exception
     */
    throw "render should return ComponentDescription or List<ComponentDescription>";
  }
  
  return children;
}

