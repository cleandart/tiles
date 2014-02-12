part of tiles;

/**
 * DomTextComponent represents text node in DOM. If there is string passed in children, 
 * it will be "packed" into DomTextComponent in synthetic DOM.
 */
class DomTextComponent extends Component {
  
  DomTextComponent(String props): super(props);
  
}

ComponentDescriptionFactory _domTextComponentDescriptionFactory = 
  registerComponent(([String props, children]) => new DomTextComponent(props));
