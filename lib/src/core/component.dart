part of library;

class Component {

  Props get props {}
  
  void set props(Props newProps) {}

  Component(Node node, Props props) {}
  
  didMount() {}

  willReceiveProps(Props newProps) {}
  
  shouldUpdate(Props newProps, Props oldProps) {}
  
  List<ComponentDescription> render() {}
  
  didUpdate() {}
  
  willUnmount() {}
  
  
}
