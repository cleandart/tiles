part of tiles_browser;

const _REF = "ref";

/**
 * definition of type for reference in props, 
 * to easyli check that ref is function with one Component argument
 */
typedef void _Ref(Component component); 

/**
 * Mount component into the html element. 
 * 
 * That means, that render structure described 
 * in the component description into element 
 */
mountComponent(ComponentDescription description, html.HtmlElement mountRoot) {
  Node node = new Node(null, description.createComponent());
  
  _rootNodes.add(node);
  
  _mountNode(node, mountRoot, true);
}

/**
 * Mount node into html element.
 *  
 * That means, it render it's tree structure into element.
 */
_mountNode(Node node, html.HtmlElement mountRoot, [bool clear = false, Node nextNode]) {
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
    html.Text text = new html.Text(node.component.props);
    _nodeToElement[node] = text;
    if (nextNode != null) {
      mountRoot.insertBefore(text, _nodeToElement[nextNode]);
    } else {
      mountRoot.append(text);
    }

  } else if (node.component is DomComponent) {
    /**
     * if component is dom component, 
     * * create new element for it,
     * * fill it's attrs by component's props, 
     * * run recursion with children 
     * * and place it into mountRoot
     */
  
    DomComponent component = node.component;
    html.Element componentElement = new html.Element.tag(component.tagName);
    component.props.forEach((key, value) {
      componentElement.setAttribute(key, value.toString());
    });
    _nodeToElement[node] = componentElement;
    
    node.children.forEach((NodeWithFactory nodeWithFactory) => _mountNode(nodeWithFactory.node, componentElement));
    
    if (nextNode != null) {
      mountRoot.insertBefore(componentElement, _nodeToElement[nextNode]);
    } else {
      mountRoot.children.add(componentElement);
    }
  } else {
    /**
     * if component is custom component, 
     * then just run recursion for children on the same element
     */
    _nodeToElement[node] = mountRoot;
    node.children.forEach((NodeWithFactory nodeWithFactory) {
      _mountNode(nodeWithFactory.node, mountRoot, false, nextNode); 
    });
  }
  
  /**
   * if component have map-like props and have _Ref in "ref" key, 
   * execute it with the coponent as argument
   */
  try {
    if (node.component.props != null 
        && node.component.props[_REF] != null
        && node.component.props[_REF] is _Ref) {
      node.component.props[_REF](node.component);
    }
  } catch (e) {}
}

/**
 * Map needed when doing updates on dom. 
 * 
 * For easy identifying place, where nodeChange should be applyed.
 */
Map<Node, dynamic> _nodeToElement = {};

List<Node> _rootNodes = [];

/**
 * Init browser configuration to proper function of library.
 * 
 * It initialize _needUpdate streem and set callback on it.
 */
initTilesBrowserConfiguration() {
}

