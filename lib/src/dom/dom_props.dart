part of tiles_dom;


class DomProps extends Props implements Map<String, dynamic> {

  /**
   * because of constructor, it needs own implementation of _children
   */
  List<ComponentDescription> _children;

  /**
   * getter for children. 
   */
  List<ComponentDescription> get children => _children;
  
  final Map<String, dynamic> _map;
  
  DomProps([Map map, List<ComponentDescription> children]):
    this._children = children != null ? children : (map != null ? map["children"] : null), 
    this._map = map != null ? map : new Map()
    {}
  
  
  
  /**
   * proxy getters and operations for map
   */
  
  Iterable<String> get keys => _map.keys;
  
  bool get isEmpty => _map.isEmpty;
  
  int get length => _map.length;
  
  Iterable<dynamic> get values => _map.values;

  remove(String key) => _map.remove(key);
  
  bool get isNotEmpty => _map.isNotEmpty;
  
  putIfAbsent(key, callback) => _map.putIfAbsent(key, callback);
  
  forEach(function) => _map.forEach(function);
  
  addAll(DomProps props) => _map.addAll(props._map);
  
  clear() => _map.clear();
  
  bool containsKey(String key) => _map.containsKey(key);
  
  bool containsValue(dynamic value) => _map.containsValue(value);
 
  operator [](String key) => _map[key];
  
  void operator []=(String key, dynamic value) => _map[key] = value;
  
  
  /**
   * Html attributes generator. 
   * 
   * Generate attributes in html syntas attr="value" for future use in DomComponent.
   */
  String htmlAttrs(){
    StringBuffer result = new StringBuffer();
    
    _map.forEach((String key, dynamic value){
      result.write(' $key="$value"');
    });
    
    return result.toString();
  }
}