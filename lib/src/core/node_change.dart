part of library;

class NodeChange {
  final NodeChangeType _type;
  final Node _node;
  final Props _oldProps;
  final Props _newProps;

  
  NodeChangeType get type => _type;
  Node get node => _node;
  Props get oldProps => _oldProps;
  Props get newProps => _newProps;
  
  NodeChange(NodeChangeType this._type, Node this._node, [Props this._oldProps, Props this._newProps]);
  
}