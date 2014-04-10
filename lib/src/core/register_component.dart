part of tiles;/**
 * Create component description factory from component factory,
 * which is function, which return component description and get props and children as parameters.
 *
 * Basic usage:
 *
 *     class MyComponent extends Component {}
 *     /*...*/
 *     ComponentDescriptionFactory myComponent = registerComponent(([dynamic props]) => new MyComponent(props));
 *     /*...*/
 *     var props = new MyProps(myArgs);
 *     var children = [/*...*/];
 *     ComponentDescription child = myComponent(props, children);
 */
ComponentDescriptionFactory registerComponent(ComponentFactory factory) {
  logger.finest("component registered");
  return ({dynamic props, dynamic children, dynamic key}) {
    logger.finest("Component description factory called");
    /**
     * parse children, as they can be in different forms
     *
     * here is the place, where strings are converted to DomTextComponent description factory
     */
    children = _processChildren(children);
    return new ComponentDescription(factory, props: props, children: children, key: key);
  };
}
