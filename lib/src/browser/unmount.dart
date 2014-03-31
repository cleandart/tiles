part of tiles_browser;

unmountComponent(html.Element mountRoot) {
  Node node = _elementToNode[mountRoot];
  if (node == null && mountRoot.children.length == 1) {
    node = _elementToNode[mountRoot.firstChild];
  }
  
  if (node != null) {
    _unmountNode(node);
    mountRoot.children.clear();
  }
}

_unmountNode(Node node) {
  node.children.forEach((Node child) {
    _unmountNode(child);
  });
  _deleteRelations(node, _nodeToElement[node]);
}

