class DocumentSnapshot {
  final String description;
  final String uid;
  final String username;
  final List likes;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final String profImage;
  const DocumentSnapshot(
      {required this.description,
      required this.uid,
      required this.username,
      required this.likes,
      required this.postId,
      required this.datePublished,
      required this.postUrl,
      required this.profImage,
      });
  //它返回一个文档的数据，可能是一个Map或者null。
  data() {
    return {
      "description": description,
      "uid": uid,
      "likes": likes,
      "username": username,
      "postId": postId,
      "datePublished": datePublished,
      'postUrl': postUrl,
      'profImage': profImage
    };
  }
}