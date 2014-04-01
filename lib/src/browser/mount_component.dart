part of tiles_browser;

const _REF = "ref";

/**
 * Map needed when doing updates on dom.
 *
 * For easy identifying place, where nodeChange should be applyed.
 */
final Map<Node, html.Node> _nodeToElement = {};

final List<Node> _rootNodes = [];

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
  Node node = new Node.fromDescription(null, description);

  _rootNodes.add(node);

  node.update();

  mountRoot.children.clear();

  _mountNode(node, mountRoot);
}

/**
 * Mount node into html element.
 *
 * That means, it render it's tree structure into element.
 */
_mountNode(Node node, html.HtmlElement mountRoot, [Node nextNode]) {
  /**
   * update to build full node tree structure
   */
  if (node.component is DomTextComponent) {
    /**
     * if node contains text, write text and end recursion
     */
    html.Text text = new html.Text(node.component.props);
    _saveRelations(node, text);
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
    _saveRelations(node, componentElement);

    component.props.forEach((String key, value) {
      /**
       * filter props by allowedAttrs and allowedSvgAttrs
       */
      if (_canAddAttribute(component, key)) {
        componentElement.setAttribute(key, value.toString());
      } else {
        _processEvent(key, value, node);
      }
    });
    node.children.forEach((Node child) => _mountNode(child, componentElement));

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
    node.children.forEach((Node child) {
      _mountNode(child, mountRoot, nextNode);
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
 * Returns boolean which is true
 * if attribute with passed key can be added
 * to element of component from arguments.
 */
_canAddAttribute(DomComponent component, String key) {
  return (!component.svg && allowedAttrs.contains(key))
      || (component.svg && allowedSvgAttributes.contains(key));

}

/**
 * create relations for propper functionality of tiles_browser
 */
void _saveRelations(Node node, html.Node element) {
  _nodeToElement[node] = element;
  _componentToElement[node.component] = element;
  _elementToNode[element] = node;
}

/**
 * Remove relations between node and element.
 */
void _deleteRelations(Node node, html.Node element) {
  _nodeToElement.remove(node);
  _componentToElement.remove(node.component);
  _elementToNode.remove(element);

}

