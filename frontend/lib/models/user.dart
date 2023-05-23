

//账号、密码、用户名、头像、简介
import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';

import '../utils/uint8list_converter.dart';
part 'user.g.dart';

@JsonSerializable(converters: [Uint8ListConverter()])
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

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
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

  // Map<String, dynamic> toJson() => {
  //   "username": username,
  //   "uid": uid,
  //   "email": email,
  //   "password":password,
  //   "jwt":jwt,
  //   "photoUrl": photoUrl,
  //   "photo":photo,
  //   "nickname": nickname,
  //   "profile":profile,
  //   "followers": followers,
  //   "following": following,
  // };
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

  User.fromDb(Map<String, dynamic> db):
        password = db['password'] ?? '',
        uid = db['uid'],
        jwt = db['jwt'] ?? '',
        photoUrl = db['photoUrl'] ?? '',
        photo = db['photo'] ?? null,
        username = db['username'],
        nickname = db['nickname'],
        profile = db['profile'],
        followers = db['followers'] ?? [],
        following = db['following'] ?? [],
        email = db['email'] ?? '';

  Map<String, dynamic> toDbMap() => <String ,dynamic>{
    "password":password,
    "uid": uid,
    "jwt":jwt,
    "photoUrl": photoUrl,
    "photo":photo,
    "username": username,
    "nickname": nickname,
    "profile":profile,
    "followers": followers,
    "following": following,
    "email": email,
  };


}