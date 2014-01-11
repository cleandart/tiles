part of library;

class Props {
  List<ComponentDescription> _children;
  /**
   * getter and setter for children. 
   * 
   * By default do nothing, because by default props don't have children.
   * 
   * But to good working api in Component factory, wee need this "value" in every props;
   */
  void set children(List<ComponentDescription> children) { 
    _children = children; 
  }
  List<ComponentDescription> get children => _children;
  
}