class Message {
  String id;
  int senderId;
  int receiverId;
  String content;
  DateTime created;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.created,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      senderId: json['sender_id'] as int,
      receiverId: json['receiver_id'] as int,
      content: json['content'] as String,
      created: DateTime.parse(json['created']),
    );
  }

  static List<Message> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Message.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "senderId": senderId,
      "receiverId": receiverId,
      "content": content,
      "created": created.toIso8601String(),
    };
  }
}