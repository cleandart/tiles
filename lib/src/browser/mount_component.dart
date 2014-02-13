part of tiles;

/**
 * Mount component into the html element. 
 * 
 * That means, that render structure described 
 * in the component description into element 
 */
mountComponent(ComponentDescription description, HtmlElement mountRoot) {
  Node node = new Node(null, description.createComponent());
  _mountNode(node, mountRoot, true);
}

/**
 * Mount node into html element.
 *  
 * That means, it render it's tree structure into element.
 */
_mountNode(Node node, HtmlElement mountRoot, [bool clear = false]) {
  /**
   * first if param clear is true, clear this html element
   */
  if (clear) {
    mountRoot.children.clear();
  }
  
  /**
   * update to build full node tree structure 
   */
  node.update();
  
  if (node.component is DomTextComponent) {
    /**
     * if node contains text, write text and end recursion
     */
    Text text = new Text(node.component.props);
    _nodeToElement[node] = text;
    mountRoot.append(text);

  } else if (node.component is DomComponent) {
    /**
     * if component is dom component, 
     * * create new element for it,
     * * fill it's attrs by component's props, 
     * * run recursion with children 
     * * and place it into mountRoot
     */
  
    DomComponent component = node.component;
    Element componentElement = new Element.tag(component.tagName);
    component.props.forEach((key, value) => componentElement.setAttribute(key, value));
    _nodeToElement[node] = componentElement;
    
    node.children.forEach((node) => _mountNode(node, componentElement));
    
    mountRoot.children.add(componentElement);
  } else {
    /**
     * if component is custom component, 
     * then just run recursion for children on the same element
     */
    _nodeToElement[node] = mountRoot;
    node.children.forEach((node) => _mountNode(node, mountRoot));
  }
}

/**
 * Map needed when doing updates on dom. 
 * 
 * For easy identifying place, where nodeChange should be applyed.
 */
Map<Node, dynamic> _nodeToElement = {};

