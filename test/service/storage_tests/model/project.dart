import 'package:scaibu_mutex_lock/service/storage/storage_engine.dart';
import 'package:uuid/uuid.dart';

import 'todo_list.dart';

class Project implements StorableModel {
  Project({
    required this.title,
    required this.description,
    final String? id,
    final Map<String, TodoList>? todoLists,
    final List<String>? members,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       todoLists = todoLists ?? <String, TodoList>{},
       members = members ?? <String>[],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Project.fromJson(final Map<String, dynamic> json) {
    final Map<String, TodoList> todoListsMap = <String, TodoList>{};
    (json['todoLists'] as Map<String, dynamic>).forEach((
      final String key,
      final dynamic value,
    ) {
      todoListsMap[key] = TodoList.fromJson(value as Map<String, dynamic>);
    });

    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      todoLists: todoListsMap,
      members: List<String>.from(json['members'] as List<dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  final String id;
  final String title;
  final String description;
  final Map<String, TodoList> todoLists;
  final List<String> members;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> todoListsJson = <String, dynamic>{};
    todoLists.forEach((final String key, final TodoList value) {
      todoListsJson[key] = value.toJson();
    });

    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'todoLists': todoListsJson,
      'members': members,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  Project copyWith({
    final String? id,
    final String? title,
    final String? description,
    final Map<String, TodoList>? todoLists,
    final List<String>? members,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) => Project(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    todoLists: todoLists ?? Map<String, TodoList>.from(this.todoLists),
    members: members ?? List<String>.from(this.members),
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  // Helper methods
  Project addTodoList(final TodoList todoList) {
    final Map<String, TodoList> updatedLists = Map<String, TodoList>.from(
      todoLists,
    );
    updatedLists[todoList.id] = todoList;
    return copyWith(todoLists: updatedLists, updatedAt: DateTime.now());
  }

  Project updateTodoList(final TodoList todoList) => addTodoList(todoList);

  Project removeTodoList(final String todoListId) {
    final Map<String, TodoList> updatedLists = Map<String, TodoList>.from(
      todoLists,
    )..remove(todoListId);
    return copyWith(todoLists: updatedLists, updatedAt: DateTime.now());
  }

  Project addMember(final String memberId) {
    if (members.contains(memberId)) {
      return this;
    }
    final List<String> updatedMembers = List<String>.from(members)
      ..add(memberId);
    return copyWith(members: updatedMembers, updatedAt: DateTime.now());
  }

  Project removeMember(final String memberId) {
    final List<String> updatedMembers =
        members.where((final String m) => m != memberId).toList();
    return copyWith(members: updatedMembers, updatedAt: DateTime.now());
  }
}
