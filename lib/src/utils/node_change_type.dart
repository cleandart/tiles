part of library;

/**
 * Create enum of type of node change.
 */

class NodeChangeType {
  static const CREATED = const NodeChangeType._(0);
  static const UPDATED = const NodeChangeType._(1);
  static const MOVED   = const NodeChangeType._(2);
  static const DELETED = const NodeChangeType._(3);

  static get values => [CREATED, UPDATED, MOVED, DELETED];

  final int value;

  const NodeChangeType._(this.value);
  
  String toString(){
    return {
      CREATED: "CREATED",
      UPDATED: "UPDATED",
      MOVED: "MOVED",
      DELETED: "DELETED"
    }[this];
//    if (this == CREATED)
//      return "CREATED";
//    if (this == UPDATED)
//      return "UPDATED";
//    if (this == MOVED)
//      return "MOVED";
//    if (this == DELETED)
//      return "DELETED";
  }
}

main () {
  print(NodeChangeType.CREATED);
  print(NodeChangeType.UPDATED);
  print(NodeChangeType.MOVED);
  print(NodeChangeType.DELETED);
  
}