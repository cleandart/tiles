part of library;

class Component {
  
  /**
   * internal representation of props
   */
  Props _props;

  /**
   * stream controller used to signalize to node, 
   * when component need to be udpated
   */
  final StreamController _needUpdateController;

  Props get props => _props;
  
  void set props(Props newProps) { 
    _props = newProps;
  }
  
  /**
   * Offer stream which will create event everytime, when it need to be updated (rendered ).
   * 
   * Stream use boolean data, which tells, if update should be done immediately
   */
  Stream<bool> get needUpdate => _needUpdateController.stream; 

  /**
   * constructor, it create component with setted stream controller. 
   * 
   * If stream was not passed, it will create own stream controller
   */
  Component(Props this._props, [StreamController needUpdateController]): 
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
  redraw([bool now = false]){
    _needUpdateController.add(now);
  }
  
  
}
