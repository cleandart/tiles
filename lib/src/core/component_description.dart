part of tiles;

class ComponentDescription {
  final ComponentFactory factory;
  
  final dynamic props;
  
  final List<ComponentDescription> children;
  
  /**
   * default constructor which only set final vars.
   */
  ComponentDescription (ComponentFactory this.factory, [dynamic  this.props, this.children]) {}
  
  /**
   * creates component by factory with props.
   */
  Component createComponent() => this.factory(this.props, this.children);
  
}
