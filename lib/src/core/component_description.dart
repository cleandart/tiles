part of tiles;

class ComponentDescription {
  final ComponentFactory factory;

  final dynamic props;

  final List<ComponentDescription> children;

  final dynamic key;

  final Map listeners;

  /**
   * default constructor which only set final vars.
   */
  ComponentDescription (ComponentFactory this.factory, {dynamic  this.props, this.children, this.key, this.listeners}) {}

  /**
   * creates component by factory with props.
   */
  Component createComponent() => this.factory(props: this.props, children: this.children);

}
