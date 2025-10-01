import 'package:scaibu_mutex_lock/service/storage/storage_engine.dart';
import 'package:uuid/uuid.dart';

class Task implements StorableModel {
  /// Task model
  Task({
    required this.title,
    required this.description,
    final String? id,
    this.isCompleted = false,
    final DateTime? createdAt,
    this.completedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory Task.fromJson(final Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    isCompleted: json['isCompleted'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    completedAt:
        json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
  );

  @override
  final String id;

  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  @override
  Task copyWith({
    final String? id,
    final String? title,
    final String? description,
    final bool? isCompleted,
    final DateTime? createdAt,
    final DateTime? completedAt,
    final bool clearCompletedAt = false,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
  );
}
