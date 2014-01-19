part of tiles;

class Component {
  
  /**
   * props of component
   */
  Props props;

  /**
   * stream controller used to signalize to node, 
   * when component need to be udpated
   */
  final StreamController _needUpdateController;

  /**
   * Offer stream which will create event everytime, when it need to be updated (rendered).
   * 
   * Stream use boolean data, which tells, if update should be done immediately
   */
  Stream<bool> get needUpdate => _needUpdateController.stream; 

  /**
   * constructor, it create component with setted stream controller. 
   * 
   * If stream was not passed, it will create own stream controller
   */
  Component(Props this.props, [StreamController needUpdateController]): 
    this._needUpdateController = needUpdateController != null ? needUpdateController : new StreamController<bool>() {}
  
  didMount() {}

  willReceiveProps(Props newProps) {}
  
  shouldUpdate(Props newProps, Props oldProps) => true;
  
  List<ComponentDescription> render() {}
  
  didUpdate() {}
  
  willUnmount() {}
  
  /**
   * redraw will add event to stream
   */
  redraw([bool now = false]) {
    _needUpdateController.add(now);
  }
  
  
}

/**
 * Create component description factory from component factory, 
 * which is function, which return component description and get props and children as parameters.
 * 
 * Basic usage:
 * 
 *     class MyComponent extends Component {}
 *     /*...*/
 *     ComponentDescriptionFactory myComponent = registerComponent(([Props props]) => new MyComponent(props));
 *     /*...*/
 *     var props = new MyProps(myArgs);
 *     var children = [/*...*/];
 *     ComponentDescription child = myComponent(props, children);  
 */
ComponentDescriptionFactory registerComponent(ComponentFactory factory) {
  return ([Props props, List<ComponentDescription> children]) {
    if (props != null && children != null) {
      props.children = children;
    }
    
    return new ComponentDescription(factory, props);
  };
}
