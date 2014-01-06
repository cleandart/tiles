part of library;

abstract class NodeChangeInterface {
  NodeChangeType get type;
  NodeInterface get node;
  PropsInterface get oldProps;
  PropsInterface get newProps;
  NodeChangeInterface(NodeChangeType type, NodeInterface node, [PropsInterface oldProps, PropsInterface newProps]);
  
}