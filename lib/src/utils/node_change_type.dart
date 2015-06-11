part of tiles;

/**
 * Create enum of type of node change.
 */

class NodeChangeType {
  static const CREATED = const NodeChangeType._(0);
  static const UPDATED = const NodeChangeType._(1);
  static const MOVED = const NodeChangeType._(2);
  static const DELETED = const NodeChangeType._(3);

  static List<NodeChangeType> get values => [CREATED, UPDATED, MOVED, DELETED];

  final int value;

  const NodeChangeType._(this.value);

  String toString() {
    return {
      CREATED: "CREATED",
      UPDATED: "UPDATED",
      MOVED: "MOVED",
      DELETED: "DELETED"
    }[this];
  }
}
