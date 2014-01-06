part of library;

class NodeChange implements NodeChangeInterface {
  final NodeChangeType _type;
  final NodeInterface _node;
  final NodeInterface _newNode;
  final PropsInterface _oldProps;
  final PropsInterface _newProps;

  
  NodeChangeType get type => _type;
  NodeInterface get node => _node;
  NodeInterface get newNode => _newNode;
  PropsInterface get oldProps => _oldProps;
  PropsInterface get newProps => _newProps;
  
  NodeChange(NodeChangeType this._type, NodeInterface this._node, [NodeInterface this._newNode, PropsInterface this._oldProps, PropsInterface this._newProps]);
  
}