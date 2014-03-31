part of tiles;

_updateChildren (Node node) {
  List<NodeChange> result = [];
  
  /**
   * get old children from node, next children descriptions from component and prepare next children map 
   */
  Map<dynamic, Node> oldChildren = _createChildrenMap(node.children);
  List<Node> nextChildren = [];
  
  
  List<ComponentDescription> descriptions = _getChildrenFromComponent(node.component);
  for(num i = 0; i < descriptions.length; ++i){
    dynamic key = descriptions[i].key;
    if(key == null) key = i;
    
    ComponentDescription description = descriptions[i];
    Node oldChild = oldChildren[key];
    Node nextChild;
    bool justCreated = false;
    
    /**
     * if factory is same, just apply new props
     */
    if (oldChild != null && oldChild.factory == description.factory) {
      nextChild = oldChild;
      nextChild.apply(description.props, description.children);
      result.add(new NodeChange(NodeChangeType.MOVED, nextChild));

      result.addAll(nextChild.update());
      oldChildren.remove(key);
    } else {
      /**
       * else create new node and if necessery, remove old one
       */
      nextChild = new Node.fromDescription(node, description);
      nextChild.update();
      result.add(new NodeChange(NodeChangeType.CREATED, nextChild));
      justCreated = true;

      if (oldChild != null) {
        result.add(new NodeChange(NodeChangeType.DELETED, oldChild));
        oldChildren.remove(key);
      }
    }
    nextChildren.add(nextChild);
  }
  for (dynamic key in oldChildren.keys) {
    result.add(new NodeChange(NodeChangeType.DELETED, oldChildren[key]));
  }
  
  node.children = nextChildren;
  
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


List<ComponentDescription> _getChildrenFromComponent(Component component) {
  var rawChildren = component.render();
  if (rawChildren is ComponentDescription) {
    /**
     * if render returns componentDescription, construct newChildren list
     */
    return [rawChildren];
  } else if (rawChildren is List<ComponentDescription>) {
    /**
     * if render returns List<componentDescription> set newChildren to it
     */
    return rawChildren;
  } else if (rawChildren == null) {
    /** 
     * if component don't render anything and return null instead of empty list,
     * replace null with empty list. 
     */
    return [];
  } else {
    /**
     * if it returns something else, throw exception
     */
    throw "render should return ComponentDescription or List<ComponentDescription>";
  }
}

