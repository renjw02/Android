

import 'dart:convert';

class Comment {
  int id;
  int userId;
  int postId;
  int commentId;
  String content;
  DateTime created;
  DateTime updated;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.commentId,
    required this.content,
    required this.created,
    required this.updated,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      userId: json['userId'] as int,
      postId: json['postId'] as int,
      commentId: json['commentId'] as int,
      content: json['content'] as String,
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'postId': postId,
      'commentId': commentId,
      'content': content,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
  Map<String, dynamic> toDbMap() {
    final map = <String, dynamic>{
      'id': id,
      'userId': userId,
      'postId': postId,
      'commentId': commentId,
      'content': content,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
    return map;
  }

  // Comment.fromMap(Map<String, dynamic> map) {
  //   id = map['id'];
  //   userId = map['userId'];
  //   postId = map['postId'];
  //   commentId = map['commentId'];
  //   content = map['content'];
  //   created = DateTime.parse(map['created']);
  //   updated = DateTime. parse(map['updated']);
  // }
  factory Comment.fromDbMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as int,
      userId: map['userId'] as int,
      postId: map['postId'] as int,
      commentId: map['commentId'] as int,
      content: map['content'] as String,
      created: DateTime.parse(map['created'] as String),
      updated: DateTime.parse(map['updated'] as String),
    );
  }

  @override
  String toString() {
    return 'Comment{id: $id, userId: $userId, postId: $postId, commentId: $commentId, content: $content, created: $created, updated: $updated}';
  }

  static Comment fromString(String str) {
    final parts = str.split(',');
    final id = int.parse(parts[0].split(':')[1].trim());
    final userId = int.parse(parts[1].split(':')[1].trim());
    final postId = int.parse(parts[2].split(':')[1].trim());
    final commentId = int.parse(parts[3].split(':')[1].trim());
    final content = parts[4].split(':')[1].trim();
    final created = DateTime.parse(parts[5].split(':')[1].trim());
    final updated =DateTime.parse(parts[6].split(':')[1].trim());

    return Comment(
      id: id,
      userId: userId,
      postId: postId,
      commentId: commentId,
      content: content,
      created: created,
      updated: updated,
    );
  }
}