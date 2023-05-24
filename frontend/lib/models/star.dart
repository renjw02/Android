class Star {
  final int id;
  final String userId;
  final int postId;
  final String title;
  final DateTime created;

  Star({
    required this.id,
    required this.userId,
    required this.postId,
    required this.title,
    required this.created
  });

  factory Star.fromJson(Map<String, dynamic> json) {
    return Star(
        id: json['id'],
        userId: json['user_id'],
        postId: json['post_id'],
        title: json['title'],
        created: DateTime.parse(json['created'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'title': title,
      'created': created.toIso8601String()
    };
  }
}