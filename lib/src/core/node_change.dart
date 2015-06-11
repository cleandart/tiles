part of tiles;

class NodeChange {
  final NodeChangeType type;
  final Node node;
  final dynamic oldProps;
  final dynamic newProps;
  final Map oldListeners;
  final Map newListeners;

  NodeChange(NodeChangeType this.type, Node this.node, {dynamic this.oldProps,
      dynamic this.newProps, this.oldListeners, this.newListeners});
}
