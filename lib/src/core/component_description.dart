part of library;

class ComponentDescription {
  ComponentFactory get factory {}
  
  Props get props {}
  
  ComponentDescription (ComponentFactory factory, Props  props) {}
  
  Component createComponent() {}
  
}