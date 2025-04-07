import 'package:scaibu_mutex_lock/service/storage/storage_engine.dart';
import 'package:uuid/uuid.dart';

class Comment implements StorableModel {
  Comment({
    required this.content,
    required this.authorId,
    final String? id,
    this.parentId = '',
    final List<Comment>? replies,
    final DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       replies = replies ?? <Comment>[],
       createdAt = createdAt ?? DateTime.now();

  factory Comment.fromJson(final Map<String, dynamic> json) {
    List<Comment> repliesList = <Comment>[];
    if (json.containsKey('replies') && json['replies'] != null) {
      repliesList =
          (json['replies'] as List<dynamic>)
              .map(
                (final dynamic reply) =>
                    Comment.fromJson(reply as Map<String, dynamic>),
              )
              .toList();
    }

    return Comment(
      id: json['id'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      parentId: json['parentId'] as String? ?? '',
      replies: repliesList,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  final String id;
  final String content;
  final String authorId;
  final String parentId; // null or empty for root comments
  final List<Comment> replies;
  final DateTime createdAt;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'content': content,
    'authorId': authorId,
    'parentId': parentId,
    'replies': replies.map((final Comment reply) => reply.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  Comment copyWith({
    final String? id,
    final String? content,
    final String? authorId,
    final String? parentId,
    final List<Comment>? replies,
    final DateTime? createdAt,
  }) => Comment(
    id: id ?? this.id,
    content: content ?? this.content,
    authorId: authorId ?? this.authorId,
    parentId: parentId ?? this.parentId,
    replies: replies ?? List<Comment>.from(this.replies),
    createdAt: createdAt ?? this.createdAt,
  );

  // Helper method to add a reply
  Comment addReply(final Comment reply) {
    final List<Comment> updatedReplies = List<Comment>.from(replies)
      ..add(reply);
    return copyWith(replies: updatedReplies);
  }

  // Helper method to find and update a comment in the tree
  Comment updateCommentInTree(final String commentId, final String newContent) {
    if (id == commentId) {
      return copyWith(content: newContent);
    }

    final List<Comment> updatedReplies =
        replies
            .map(
              (final Comment reply) =>
                  reply.updateCommentInTree(commentId, newContent),
            )
            .toList();

    return copyWith(replies: updatedReplies);
  }

  // Find a comment by id in the tree
  Comment? findCommentById(final String commentId) {
    if (id == commentId) {
      return this;
    }

    for (final Comment reply in replies) {
      final Comment? found = reply.findCommentById(commentId);
      if (found != null) {
        return found;
      }
    }

    return null;
  }
}
