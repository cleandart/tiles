part of library;

abstract class PropsInterface {
  void mergeIn(PropsInterface newProps);
 
  /**
   * getter and setter for children. 
   * 
   * By default do nothing, because by default props don't have children.
   * 
   * But to good working api in Component factory, wee need this "value" in every props;
   */
  void set children(List<ComponentDescriptionInterface> children);
  List<ComponentDescriptionInterface> get children;
  
}