part of tiles_browser;

/**
 * Map used to listen event.target to Node instance.
 *
 * When event is bubbled up to root node element,
 * it is catched and then targetNode is identified by this map.
 */
final Map<html.Node, Node> _elementToNode = {};

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
 * Helper function which create map for events,
 * which tell's for each tiles evnt which real event should be mapped to it.
 *
 * As imput take's list like
 *     [
 *       "click",
 *       "mouseDown",
 *       /*..*/
 *     ]
 *
 * It looks like
 *     {
 *       "onClick": "click",
 *       "onMouseDown": "mousedown",
 *       /*...*/
 *     }
 */
Map<String, String> _createEventsMapFromList(List<String> events) {
  Map<String, String> eventsMap = {};
  events.forEach((event) {
    if (event.length > 0) {
      event = event[0].toUpperCase() + event.substring(1);
    }
    eventsMap["on$event"] = event.toLowerCase();
  });
  return eventsMap;
}

/**
 * Map of all supported events.
 *
 * Created by _createEventsMapFromList
 */
final Map<String, String> allowedEvents = _createEventsMapFromList(["keyDown",
  "keyPress", "keyUp", "focus", "blur", "change", "input", "submit", "click",
  "doubleClick", "drag", "dragEnd", "dragEnter", "dragExit", "dragLeave",
  "dragOver", "dragStart", "drop", "mouseDown", "mouseEnter", "mouseLeave",
  "mouseMove", "mouseOut", "mouseOver", "mouseUp", "touchCancel", "touchEnd",
  "touchMove", "touchStart", "scroll", "wheel",
]);

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
  if (allowedEvents.containsKey(key)) {
    if (!(value is EventListener)) {
      throw "there can be only EventListener in $key attribute";
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
  
        if (listener != null && listener(targetNode.component, event) == false) {
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
    element.on[allowedEvents[event]].listen(_handleEventType(event));
    registeredListeners.add(event);
  }
}

/**
 * Map which saves which element have which events allready registered
 */
final Map<html.Element, Set<String>>_registeredListeners = {};

