part of tiles_browser;

const _REF = "ref";
const _VALUE = "value";
const _DEFAULTVALUE = "defaultValue";
const _DANGEROUSLYSETINNERHTML = "dangerouslySetInnerHTML";

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
  logger.fine("mountComponent called");
  
  if(_isMounted(description, mountRoot)) {
    return _remountDescription(description, mountRoot);
  }

  Node node = new Node.fromDescription(null, description);

  _rootNodes.add(node);

  node.update();

  mountRoot.children.clear();

  _mountNode(node, mountRoot);

  /**
   * mount root node to mount root to be able easy unmount node.
   */
  _elementToNode[mountRoot] = node;
}

void _remountDescription(ComponentDescription description, html.HtmlElement mountRoot) {
  Node node = _elementToNode[mountRoot];
  node.apply(props: description.props, children: description.children, listeners: description.listeners);
  node.isDirty = true;
}

bool _isMounted(ComponentDescription description, html.HtmlElement mountRoot) {
  return _elementToNode[mountRoot] != null && _elementToNode[mountRoot].factory == description.factory;
}

/**
 * Mount node into html element.
 *
 * That means, it render it's tree structure into element.
 */
_mountNode(Node node, html.HtmlElement mountRoot, {Node nextNode}) {
  logger.fine("_mountNode called");
  /**
   * update to build full node tree structure
   */
  if (node.component is DomTextComponent) {
    logger.finer("mounting DomTextComponent");
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
    logger.finer("mounting DomComponent");
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

    _applyAttributes(componentElement, component.props, svg: component.svg, node: node, listeners: node.listeners);
    if(component.props.containsKey(_DANGEROUSLYSETINNERHTML)){
      _dangerouslySetInnerHTML(component, componentElement);
    } else {
      node.children.forEach((Node child) => _mountNode(child, componentElement));
    }

    if (nextNode != null) {
      mountRoot.insertBefore(componentElement, _nodeToElement[nextNode]);
    } else {
      mountRoot.children.add(componentElement);
    }
  } else {
    logger.finer("mounting custom component");
    /**
     * if component is custom component, apply event listeners
     * and then just run recursion for children on the same element
     */
    _nodeToElement[node] = mountRoot;
    _applyEventListeners(node.listeners, node);

    node.children.forEach((Node child) {
      _mountNode(child, mountRoot, nextNode: nextNode);
    });
  }
  /**
   * call didMount life-cycle on component
   */
  node.component.didMount();

  /**
   * if component have map-like props and have _Ref in "ref" key,
   * execute it with the coponent as argument
   */
  try {
    if (node.component.props != null
        && node.component.props[_REF] != null
        && node.component.props[_REF] is _Ref) {
      logger.finest("calling reference");
      node.component.props[_REF](node.component);
    }
  } catch (e) {}
}

void _dangerouslySetInnerHTML(DomComponent component, html.Element element) {
  if(component.children != null) {
    throw new Exception("Component with dangerously setted inner html should not have childre");
  }
  element.setInnerHtml(component.props[_DANGEROUSLYSETINNERHTML]);
}

/**
 * Returns boolean which is true
 * if attribute with passed key can be added
 * to element of component from arguments.
 */
_canAddAttribute(bool svg, String key) {
  return (!svg && allowedAttrs.contains(key))
      || (svg && allowedSvgAttributes.contains(key)) 
      || _matchAllowedPrefix(key);

}

/**
 * tells if the key match some of allowed prefixes
 */
bool _matchAllowedPrefix(String key) {
  bool match = false;
  
  allowedAttrsPrefixes.forEach((prefix) {
    if (key.startsWith(prefix)) {
      match = true;
    }
  });

  return match;
}

/**
 * Applies props to element.
 *
 * If oldProps setted, use them to compare new and remove old.
 */
_applyAttributes(html.Element element, Map props, {bool svg: false, Node node, Map oldProps, Map listeners}) {
  logger.fine("_applyAttributes called");
  if (oldProps == null) {
    oldProps = {};
  } else {
    oldProps = new Map.from(oldProps);
  }

  props.forEach((String key, value) {
        /**
         * filter props by allowedAttrs and allowedSvgAttrs
         */
        if (_canAddAttribute(svg, key)) {
          if (oldProps[key] != value
              && element.getAttribute(key) != value) {
            _applyAttribute(element, key, value);
          }
          /**
           * remove key from oldProps to "mark it" as present in new props
           */
          oldProps.remove(key);
        }
  });

  /**
   * if listeners exists, apply them
   */
  _applyEventListeners(listeners, node);


  /**
   * remove old props not present in new one.
   */
  oldProps.forEach((String key, value) {
    element.attributes.remove(key);
  });


}

_applyEventListeners(Map listeners, Node node) {
  if (listeners != null) {
    listeners.forEach((String eventType, EventListener listener) {
      _processEvent(eventType, listener, node);
    });
  }
}

_applyAttribute(html.Element element, String key, dynamic value) {
  logger.finer("_applyAttribute called");
  if (element is html.InputElement || element is html.TextAreaElement) {
    /**
     * retype it to not throwing warving
     */
    if (key == _VALUE) {
      if (element.value != value.toString()) {
        element.value = value.toString();
      }
    } else if (key == _DEFAULTVALUE) {
      element.setAttribute(_VALUE, value.toString());
      return;
    }
  }
  element.setAttribute(key, value.toString());
}

/**
 * create relations for propper functionality of tiles_browser
 */
void _saveRelations(Node node, html.Node element) {
  logger.fine("_saveRelations called");
  _nodeToElement[node] = element;
  _componentToElement[node.component] = element;
  _elementToNode[element] = node;
}

/**
 * Remove relations between node and element.
 */
void _deleteRelations(Node node, html.Node element) {
  logger.fine("_deleteRelations called");
  _nodeToElement.remove(node);
  _componentToElement.remove(node.component);
  _elementToNode.remove(element);

}

