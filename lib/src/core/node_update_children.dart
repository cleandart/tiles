part of tiles;

class DummyList{
  const DummyList();
  add(var elem){}
}

// TODO: make changes parameter named
// TODO: is there any reason, why _updateChildren is not a method of Node class?
_updateChildren (Node node, [List<NodeChange> changes]) {
  /**
   * get old children from node, next children descriptions from component and prepare next children map
   */
  Map<dynamic, Node> oldChildren = _createChildrenMap(node.children);
  List<Node> nextChildren = [];
  List<ComponentDescription> descriptions = _getChildrenFromComponent(node.component);

  logger.finer('component: ${node.component.props}');

  for(num i = 0; i < descriptions.length; ++i){
    dynamic key = descriptions[i].key;
    if(key == null) {
      key = i;
    }

    ComponentDescription description = descriptions[i];
    Node oldChild = oldChildren[key];
    Node nextChild;

    /**
     * if factory is same, just apply new props
     */
    if (oldChild != null && oldChild.factory == description.factory) {
      logger.finer('same factory, updating props');
      nextChild = oldChild;
      nextChild.apply(description.props, description.children);
      _addChanges(new NodeChange(NodeChangeType.MOVED, nextChild), changes);

      nextChild.update(changes: changes, force: true);
      oldChildren.remove(key);
    } else {
      logger.finer('different factory, create & delete');
      /**
       * else create new node and if necessery, remove old one
       */
      nextChild = new Node.fromDescription(node, description);
      nextChild.update();
      _addChanges(new NodeChange(NodeChangeType.CREATED, nextChild), changes);

      if (oldChild != null) {
        _addChanges(new NodeChange(NodeChangeType.DELETED, oldChild), changes);
        oldChildren.remove(key);
      }
    }
    nextChildren.add(nextChild);
  }
  for (Node child in oldChildren.values) {
    _addChanges(new NodeChange(NodeChangeType.DELETED, child), changes);
  }
  node.children = nextChildren;
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

