import 'package:scaibu_mutex_lock/service/treeCraft/tree_repository/src/model/tree_mappable.dart';
///
class TreeTraversal<T, C> {
  /// Visits each node using Depth-First Search (DFS).
  void visitDFS(
      final TreeMappable<T, C> node,
      final void Function(TreeMappable<T, C> node) visit,
      ) {
    visit(node);
    for (final TreeMappable<T, C> child in node.children) {
      visitDFS(child, visit);
    }
  }

  /// Visits each node using Breadth-First Search (BFS).
  void visitBFS(
      final TreeMappable<T, C> node,
      final void Function(TreeMappable<T, C> node) visit,
      ) {
    final List<TreeMappable<T, C>> queue = <TreeMappable<T, C>>[node];
    while (queue.isNotEmpty) {
      final TreeMappable<T, C> current = queue.removeAt(0);
      visit(current);
      queue.addAll(current.children);
    }
  }

  /// Finds a node by ID using Depth-First Search (DFS).
  TreeMappable<T, C>? findDFS(
      final TreeMappable<T, C> node,
      final String searchId,
      ) {
    if (node.treeId == searchId) {
      return node;
    }
    for (final TreeMappable<T, C> child in node.children) {
      final TreeMappable<T, C>? result = findDFS(child, searchId);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Finds a node by ID using Breadth-First Search (BFS).
  TreeMappable<T, C>? findBFS(
      final TreeMappable<T, C> node,
      final String searchId,
      ) {
    final List<TreeMappable<T, C>> queue = <TreeMappable<T, C>>[node];
    while (queue.isNotEmpty) {
      final TreeMappable<T, C> current = queue.removeAt(0);
      if (current.treeId == searchId) {
        return current;
      }
      queue.addAll(current.children);
    }
    return null;
  }
}


///
class GenericTreeNode<T, C> implements TreeMappable<T, C> {

  ///
  GenericTreeNode({
    required this.id,
    this.data,
    final List<TreeMappable<T, C>>? children,
  }) : _children = children ?? <TreeMappable<T, C>>[];
  ///
  final String id;
  ///
  final T? data;
  final List<TreeMappable<T, C>> _children;

  @override
  String get treeId => id;

  ///
  @override
  List<TreeMappable<T, C>> get children => _children;

  @override
  T? get treeData => data;
}
