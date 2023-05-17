class Notice {
  int noticeId;
  int userId;
  int noticeType;
  int noticeCreator;
  DateTime created;
  int hasChecked;

  Notice({
    required this.noticeId,
    required this.userId,
    required this.noticeType,
    required this.noticeCreator,
    required this.created,
    required this.hasChecked,
  });


  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      noticeId: json['noticeId'],
      userId: json['userId'],
      noticeType: json['noticeType'],
      noticeCreator: json['noticeCreator'],
      created: DateTime.parse(json['created']),
      hasChecked: json['hasChecked'],
    );
  }

  static List<Notice> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Notice.fromJson(json)).toList();
  }

  data() {
    return {
      "noticeId": noticeId,
      "userId": userId,
      "noticeType": noticeType,
      "noticeCreator": noticeCreator,
      "created": created,
      "hasChecked": hasChecked,
    };
  }
}