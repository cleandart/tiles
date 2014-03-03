part of tiles;

class NodeChange {
  final NodeChangeType _type;
  final Node _node;
  final dynamic _oldProps;
  final dynamic _newProps;

  
  NodeChangeType get type => _type;
  Node get node => _node;
  dynamic get oldProps => _oldProps;
  dynamic get newProps => _newProps;
  
  NodeChange(NodeChangeType this._type, Node this._node, [dynamic this._oldProps, dynamic this._newProps]);
  
}
