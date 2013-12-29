part of library;

abstract class ComponentDescriptionInterface {
  ComponentFactory get factory;
  
  ComponentDescriptionInterface (ComponentFactory factory, PropsInterface  props);
  
  ComponentInterface createComponent([NodeInterface node]);
  
}