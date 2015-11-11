part of tiles_browser;

/**
 * Map used to listen event.target to Node instance.
 *
 * When event is bubbled up to root node element,
 * it is catched and then targetNode is identified by this map.
 */
final Map<html.Node, Node> _elementToNode = {};

/**
 * A small List used to determine if an event will bubble up to it's
 * parent. If not, we need to listen to the event on the element itself,
 * not use the optimizations of batching listening on the root element.
 */
final List<String> _nonBubblingEvents = ["scroll", "focus", "blur"];

/**
 * needed to enable user of API to get element,
 * which is component mapped to.
 */
final Map<Component, html.Node> _componentToElement = {};

/**
 * Returns html element,
 * which was created by DomComponent passed as argument.
 */
getElementForComponent(Component component) {
  return _componentToElement[component];
}

/**
 * define a type, which shoul every event listener
 * in props of DomComponent match.
 */
typedef bool EventListener(Component component, html.Event event);

/**
 * Process props key: value and if it is event listener,
 * register listener on element of root node
 */
_processEvent(String key, dynamic value, Node node) {
  logger.fine("_processEvent called on key $key");
  if (!(value is EventListener)) {
    throw "there can be only EventListener in $key attribute";
  }

  // if the event cannot bubble, skip finding root node
  if(_nonBubblingEvents.contains(key)) {
    _registerListener(_nodeToElement[node], key);
    return;
  }

  /**
     * Find root node.
     *
     * For now not very effective,
     * later it should be passed as argument.
     */
  var parent = node;
  while (parent.parent != null) {
    parent = parent.parent;
  }

  html.Element masterRoot = _nodeToElement[parent];

  _registerListener(masterRoot, key);
}

/**
 * will create listener for html.Event, which handles event by
 *
 * * detecting target node,
 * * bubbles up and process all event's listeners on the path
 * from target node to root node
 */
_handleEventType(String what) {
  logger.fine("_handleEventType called with listener $what");
  return (html.Event event) {
    logger.finer("Event $what catched and starting synthetic bubbling");
    Node targetNode = _elementToNode[event.target];

    while (targetNode != null) {
      if (targetNode.listeners != null) {
        EventListener listener;

        listener = targetNode.listeners[what];

        if (listener != null &&
            listener(targetNode.component, event) == false) {
          break;
        }
      }
      targetNode = targetNode.parent;
    }
  };
}

/**
 * register listening for specific event on element
 * and "mark" this element that is listening for this event
 * to not register another listener
 */
_registerListener(html.Element element, String event) {
  logger.fine("_registerListener called with listener $event");
  Set registeredListeners = _registeredListeners[element];
  if (registeredListeners == null) {
    registeredListeners = _registeredListeners[element] = new Set();
  }

  if (!registeredListeners.contains(event)) {
    element.on[_removeOnAndLowercase(event)].listen(_handleEventType(event));
    registeredListeners.add(event);
  }
}

/**
 * Helper function which remove on from the event listneer and lowercase first letter.
 * For example it will produce "click" from "onClick";
 */
String _removeOnAndLowercase(String event) {
  String result = event;

  result = result.replaceAll(new RegExp(r"^on"), "");

  if (result.length > 0) {
    result = result[0].toLowerCase() + result.substring(1);
  }
  return result;
}

/**
 * Map which saves which element have which events allready registered
 */
final Map<html.Element, Set<String>> _registeredListeners = {};
