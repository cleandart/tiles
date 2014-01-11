part of library;

class NodeChange {
  final NodeChangeType _type;
  final Node _node;
  final Node _newNode;
  final Props _oldProps;
  final Props _newProps;

  
  NodeChangeType get type => _type;
  Node get node => _node;
  Node get newNode => _newNode;
  Props get oldProps => _oldProps;
  Props get newProps => _newProps;
  
  NodeChange(NodeChangeType this._type, Node this._node, [Node this._newNode, Props this._oldProps, Props this._newProps]);
  
}