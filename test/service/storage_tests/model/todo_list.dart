import 'package:scaibu_mutex_lock/service/storage/storage_engine.dart';
import 'package:uuid/uuid.dart';
import 'task.dart';

class TodoList implements StorableModel {
  TodoList({
    required this.name,
    final String? id,
    final List<Task>? tasks,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       tasks = tasks ?? <Task>[],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory TodoList.fromJson(final Map<String, dynamic> json) {
    final List<Task> tasksList =
        (json['tasks'] as List<dynamic>)
            .map(
              (final dynamic taskJson) =>
                  Task.fromJson(taskJson as Map<String, dynamic>),
            )
            .toList();

    return TodoList(
      id: json['id'] as String,
      name: json['name'] as String,
      tasks: tasksList,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  final String id;
  final String name;
  final List<Task> tasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'tasks': tasks.map((final Task task) => task.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  TodoList copyWith({
    final String? id,
    final String? name,
    final List<Task>? tasks,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) => TodoList(
    id: id ?? this.id,
    name: name ?? this.name,
    tasks: tasks ?? List<Task>.from(this.tasks),
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  // Helper methods for managing tasks
  TodoList addTask(final Task task) {
    final List<Task> updatedTasks = List<Task>.from(tasks)..add(task);
    return copyWith(tasks: updatedTasks, updatedAt: DateTime.now());
  }

  TodoList updateTask(final Task task) {
    final List<Task> updatedTasks =
        tasks.map((final Task t) => t.id == task.id ? task : t).toList();
    return copyWith(tasks: updatedTasks, updatedAt: DateTime.now());
  }

  TodoList removeTask(final String taskId) {
    final List<Task> updatedTasks =
        tasks.where((final Task t) => t.id != taskId).toList();
    return copyWith(tasks: updatedTasks, updatedAt: DateTime.now());
  }
}
