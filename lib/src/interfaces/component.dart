part of library;

abstract class ComponentInterface {

  PropsInterface get props;
  
  void set props(PropsInterface newProps);

  willReceiveProps(PropsInterface newProps);
  
  shouldUpdate(PropsInterface newProps, PropsInterface oldProps);
  
  didMount();
  
  didUpdate();
  
  willUnmount();
  
  List<ComponentDescriptionInterface> render();
  
  ComponentInterface(NodeInterface node, PropsInterface props);
  
}
