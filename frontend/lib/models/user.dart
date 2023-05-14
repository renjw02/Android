

//账号、密码、用户名、头像、简介
import 'dart:typed_data';

class User {
  final String email;
  final String password;
  final String uid;
  final String jwt;
  final String photoUrl;
  final Uint8List photo;
  final String username;
  final String nickname;
  final String profile;
  final List followers;
  final List following;

  User(
      {required this.username,
        required this.uid,
        required this.jwt,
        required this.photoUrl,
        required this.photo,
        required this.email,
        required this.password,
        required this.nickname,
        required this.profile,
        required this.followers,
        required this.following});

  // static User fromSnap(DocumentSnapshot snap) {
  //   var snapshot = snap.data() as Map<String, dynamic>;
  //
  //   return User(
  //     username: snapshot["username"],
  //     uid: snapshot["uid"],
  //     email: snapshot["email"],
  //     photoUrl: snapshot["photoUrl"],
  //     bio: snapshot["bio"],
  //     followers: snapshot["followers"],
  //     following: snapshot["following"],
  //   );
  // }

  Map<String, dynamic> toJson() => {
    "username": username,
    "uid": uid,
    "email": email,
    "password":password,
    "jwt":jwt,
    "photoUrl": photoUrl,
    "photo":photo,
    "nickname": nickname,
    "profile":profile,
    "followers": followers,
    "following": following,
  };
  data() {
    return {
      "username": username,
      "uid": uid,
      "email": email,
      "password":password,
      "jwt":jwt,
      "photoUrl": photoUrl,
      "photo":photo,
      "nickname": nickname,
      "profile":profile,
      "followers": followers,
      "following": following,
    };
  }
}