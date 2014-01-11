part of library;

class Component {

  Props get props {}
  
  void set props(Props newProps) {}
  
  /**
   * Offer stream which will create event everytime, when it need to be updated (rendered ).
   * 
   * Stream use boolean data, which tells, if update should be done immediately
   */
  Stream<bool> get needUpdate {} 

  Component(Props props) {}
  
  didMount() {}

  willReceiveProps(Props newProps) {}
  
  shouldUpdate(Props newProps, Props oldProps) {}
  
  List<ComponentDescription> render() {}
  
  didUpdate() {}
  
  willUnmount() {}
  
  
}
