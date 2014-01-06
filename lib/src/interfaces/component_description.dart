part of library;

abstract class ComponentDescriptionInterface {
  ComponentFactory get factory;
  
  PropsInterface get props;
  
  ComponentDescriptionInterface (ComponentFactory factory, PropsInterface  props);
  
  ComponentInterface createComponent([NodeInterface node]);
  
}