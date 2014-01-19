part of tiles;

class ComponentDescription {
  final ComponentFactory _factory;
  ComponentFactory get factory => _factory;
  
  final Props _props;
  Props get props => _props;
  
  /**
   * default constructor which only set final vars.
   */
  ComponentDescription (ComponentFactory this._factory, [Props  this._props]) {}
  
  /**
   * creates component by factory with props.
   */
  Component createComponent() => this._factory(this.props);
  
}
