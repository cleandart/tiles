part of tiles_browser;

const _REF = "ref";
const _ELEMENT = "element";
const _ATTRIBUTES = "attributes";
const _URI_POLICY = "uriPolicy";

const bool _USE_EXISTING_DEFAULT = true;
const bool _CLEAR_NOT_USED_DEFAULT = true;

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
 * 
 * Have two aditinal arguments:
 * 
 * * useExisting: default true
 * This means, if the existing structure should be "infected", co if it is possible, used and activated listeners on it.
 * 
 * * clearNotUsed: default true
 * This means, that if there are some elements, not used in the "infection", there are cleared at the end of the mounting
 * 
 * * clearNotUsedAttributes: default clearNotUsed
 * This will remove all attributes from elements, not defined by tiles.
 * 
 * So by default, mount will use existing structure and fully modify it to represent the description. It will remove not used elements and not used attributes.
 */
mountComponent(ComponentDescription description, html.HtmlElement mountRoot,
    {bool clearNotUsed: _CLEAR_NOT_USED_DEFAULT,
    bool useExisting: _USE_EXISTING_DEFAULT,
    bool clearNotUsedAttributes: null}) {
  logger.fine("mountComponent called");

  if (clearNotUsedAttributes == null) {
    clearNotUsedAttributes = clearNotUsed;
  }

  if (_isMounted(description, mountRoot)) {
    return _remountDescription(description, mountRoot);
  }

  Node node = new Node.fromDescription(null, description);

  _rootNodes.add(node);

  node.update();

  List children = []..addAll(mountRoot.childNodes);
  Iterator iterator = children.iterator..moveNext();
  _mountNode(node, mountRoot,
      useExisting: useExisting,
      nextElement: iterator,
      clearNotUsed: clearNotUsed,
      clearNotUsedAttributes: clearNotUsedAttributes);

  _clearRest(clearNotUsed, mountRoot, iterator);

  /**
   * mount root node to mount root to be able easy unmount node.
   */
  _elementToNode[mountRoot] = node;
}

void _clearRest(bool clearNotUsed, html.HtmlElement mountRoot,
    Iterator<html.Node> iterator) {
  if (clearNotUsed && _getCurrent(iterator) != null) {
    _getCurrent(iterator).remove();
    iterator.moveNext();
    _clearRest(clearNotUsed, mountRoot, iterator);
  }
}

void _remountDescription(
    ComponentDescription description, html.HtmlElement mountRoot) {
  Node node = _elementToNode[mountRoot];
  node.apply(
      props: description.props,
      children: description.children,
      listeners: description.listeners);
  node.isDirty = true;
}

bool _isMounted(ComponentDescription description, html.HtmlElement mountRoot) {
  return _elementToNode[mountRoot] != null &&
      _elementToNode[mountRoot].factory == description.factory;
}

/**
 * Mount node into html element.
 *
 * That means, it render it's tree structure into element.
 */
_mountNode(Node node, html.HtmlElement mountRoot, {Node nextNode,
    Iterator<html.Node> nextElement, bool useExisting: false,
    bool clearNotUsed: false, bool clearNotUsedAttributes: false}) {
  /**
   * update to build full node tree structure
   */
  if (node.component is DomTextComponent) {
    logger.finer("mounting DomTextComponent");
    /**
     * if node contains text, write text and end recursion
     */
    html.Text text = _getText(node.component.props, nextElement, useExisting);
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
    html.Element componentElement =
        _getHtmlElement(component, nextElement, useExisting);
    _saveRelations(node, componentElement);

    _applyAttributes(componentElement, component.props,
        svg: component.svg,
        node: node,
        listeners: node.listeners,
        clearNotUsedAttributes: clearNotUsedAttributes);
    if (component.props.containsKey(DANGEROUSLYSETINNERHTML)) {
      _dangerouslySetInnerHTML(component, componentElement);
    } else {
      List children = []..addAll(componentElement.childNodes);
      Iterator iterator = children.iterator..moveNext();
      node.children.forEach((Node child) => _mountNode(child, componentElement,
          useExisting: true,
          nextElement: iterator,
          clearNotUsed: clearNotUsed,
          clearNotUsedAttributes: clearNotUsedAttributes));
      ;
      _clearRest(clearNotUsed, mountRoot, iterator);
    }

    if (nextNode != null) {
      mountRoot.insertBefore(componentElement, _nodeToElement[nextNode]);
    } else if (!useExisting ||
        !mountRoot.childNodes.contains(componentElement)) {
      if (_getCurrent(nextElement) == null) {
        mountRoot.children.add(componentElement);
      } else {
        mountRoot.insertBefore(componentElement, _getCurrent(nextElement));
      }
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
      _mountNode(child, mountRoot,
          nextNode: nextNode,
          useExisting: useExisting,
          nextElement: nextElement,
          clearNotUsed: clearNotUsed,
          clearNotUsedAttributes: clearNotUsedAttributes);
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
    if (node.component.props != null &&
        node.component.props[_REF] != null &&
        node.component.props[_REF] is _Ref) {
      logger.finest("calling reference");
      node.component.props[_REF](node.component);
    }
  } catch (e) {}
}

html.Text _getText(
    String content, Iterator<html.Node> nextElement, bool useExisting) {
  html.Node node = _getCurrent(nextElement);
  if (useExisting && node is html.Text) {
    node.text = content;
    nextElement.moveNext();
    return node;
  }
  return new html.Text(content);
}

html.Element _getHtmlElement(
    DomComponent component, Iterator<html.Node> nextElement, bool useExisting) {
  html.Node node = _getCurrent(nextElement);
  if (useExisting &&
      node is html.Element &&
      node.tagName.toLowerCase() == component.tagName.toLowerCase()) {
    nextElement.moveNext();
    return node;
  }
  return new html.Element.tag(component.tagName);
}

html.Node _getCurrent(Iterator<html.Node> nextElement) {
  return nextElement != null ? nextElement.current : null;
}

void _dangerouslySetInnerHTML(DomComponent component, html.Element element) {
  if (component.children != null) {
    throw new Exception(DANGEROUSLYSETINNERHTMLCHILDRENEXCEPTION);
  }

  element.setInnerHtml(component.props[DANGEROUSLYSETINNERHTML],
      validator: _createValidator(component));
}

_createValidator(DomComponent component) {
  final html.NodeValidatorBuilder _htmlValidator =
      new html.NodeValidatorBuilder.common();
  if (component.props.containsKey(DANGEROUSLYSETINNERHTMLUNSANITIZE)) {
    for (Map unsanitize in component.props[DANGEROUSLYSETINNERHTMLUNSANITIZE]) {
      _htmlValidator.allowElement(unsanitize[_ELEMENT],
          attributes: unsanitize[_ATTRIBUTES],
          uriPolicy: _regexUriPolicy(unsanitize[_URI_POLICY]));
    }
  }
  return _htmlValidator;
}

_regexUriPolicy(String regex) {
  return new RegexpUriPolicy(regex);
}

class RegexpUriPolicy implements html.UriPolicy{

  RegexpUriPolicy(String regex):
        this.regex = new RegExp(regex);

  final RegExp regex;

  bool allowsUri(String uri) {
    return regex.hasMatch(uri);
  }
}

/**
 * Applies props to element.
 *
 * If oldProps setted, use them to compare new and remove old.
 */
_applyAttributes(html.Element element, Map props, {bool svg: false, Node node,
    Map oldProps, Map listeners, bool clearNotUsedAttributes: false}) {
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
    if (canAddAttribute(svg, key)) {
      if (oldProps[key] != value && element.getAttribute(key) != value) {
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

  if (clearNotUsedAttributes) {
    _removeNotUsedAtrributes(element, props.keys);
  }
}

void _removeNotUsedAtrributes(html.Element element, Iterable keys) {
  for (String key in element.attributes.keys) {
    if (!keys.contains(key) && !(key == VALUE && keys.contains(DEFAULTVALUE))) {
      element.attributes.remove(key);
    }
  }
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
    if (key == VALUE) {
      if (element.value != value.toString()) {
        element.value = value.toString();
      }
    } else if (key == DEFAULTVALUE) {
      element.setAttribute(VALUE, value.toString());
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
