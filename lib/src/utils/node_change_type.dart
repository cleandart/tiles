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
    if (this == CREATED)
      return "CREATED";
    if (this == UPDATED)
      return "UPDATED";
    if (this == MOVED)
      return "MOVED";
    if (this == DELETED)
      return "DELETED";
  }
}