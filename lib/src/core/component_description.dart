part of tiles;

class ComponentDescription {
  final ComponentFactory _factory;
  ComponentFactory get factory => _factory;
  
  final dynamic _props;
  dynamic get props => _props;
  
  final List<ComponentDescription> _children;
  List<ComponentDescription> get children => _children;
  
  /**
   * default constructor which only set final vars.
   */
  ComponentDescription (ComponentFactory this._factory, [dynamic  this._props, this._children]) {}
  
  /**
   * creates component by factory with props.
   */
  Component createComponent() => this._factory(this.props, this.children);
  
}
