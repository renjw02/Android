import 'documentSnapshot.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final likes;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final String profImage;

  const Post(
      {required this.description,
      required this.uid,
      required this.username,
      required this.likes,
      required this.postId,
      required this.datePublished,
      required this.postUrl,
      required this.profImage,
      });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;//作用是将snap.data()转换为Map<String, dynamic>类型

    return Post(
      description: snapshot["description"],
      uid: snapshot["uid"],
      likes: snapshot["likes"],
      postId: snapshot["postId"],
      datePublished: snapshot["datePublished"],
      username: snapshot["username"],
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage']
    );
  }

   Map<String, dynamic> toJson() => {
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