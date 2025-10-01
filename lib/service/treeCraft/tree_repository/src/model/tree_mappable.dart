/// An abstract class representing a mappable tree structure where each node has
/// an identifier, a list of children nodes, and an optional data payload.
abstract class TreeMappable<T, C> {
  /// The unique identifier for this node.
  String get treeId;

  /// The list of child nodes under this node.
  List<TreeMappable<T, C>> get children;

  /// Optional data associated with this node. It can be `null` if no data
  /// is set.
  T? get treeData;
}

