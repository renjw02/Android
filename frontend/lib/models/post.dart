import 'dart:typed_data';
import 'dart:ui';

import 'documentSnapshot.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:typed_data';
import 'dart:convert' show base64, json, jsonDecode, jsonEncode, utf8;
import 'package:frontend/models/comment.dart';
part 'post.g.dart';

@JsonSerializable()
class Post {
  final int id;
  final String userId;
  final String title;
  final String nickname;
  final List<dynamic> comments;
  final String content;
  String last_replied_user_id;
  String last_replied_time;
  final String created;
  final String updated;
  final int type;
  final String position;
  int support_num;
  int comment_num;
  int star_num;
  final int font_size;
  final String font_color;
  final String font_weight;
  List<dynamic> supportList; //喜欢这个贴子的用户
  List<dynamic> starList;
  List<dynamic> images;
  List<dynamic> videos;

  // final String username;
  // final likes;
  // final String postId;
  // final DateTime datePublished;
  // final String postUrl;
  // final String profImage;
  Post({required this.id,
    required this.userId,
    required this.title,
    required this.nickname,
    required this.comments,
    required this.content,
    required this.last_replied_user_id,
    required this.last_replied_time,
    required this.created,
    required this.updated,
    required this.type,
    required this.position,
    required this.support_num,
    required this.comment_num,
    required this.star_num,
    required this.font_size,
    required this.font_color,
    required this.font_weight,
    required this.supportList,
    required this.starList,
    required this.images,
    required this.videos,
  });

  factory Post.fromJson(Map<String, dynamic> json) =>
      _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);

  // static Post fromSnap(DocumentSnapshot snap) {
  //   var snapshot = snap.data() as Map<String, dynamic>;//作用是将snap.data()转换为Map<String, dynamic>类型
  //
  //   return Post(
  //     description: snapshot["description"],
  //     uid: snapshot["uid"],
  //     likes: snapshot["likes"],
  //     postId: snapshot["postId"],
  //     datePublished: snapshot["datePublished"],
  //     username: snapshot["username"],
  //     postUrl: snapshot['postUrl'],
  //     profImage: snapshot['profImage']
  //   );
  // }


  data() {
    return {
      "id": id,
      "userId": userId,
      "title": title,
      "nickname": nickname,
      "comments": comments,
      "content": content,
      "last_replied_user_id": last_replied_user_id,
      "last_replied_time": last_replied_time,
      "created": created,
      "updated": updated,
      "type": type,
      "position": position,
      "support_num": support_num,
      "comment_num": comment_num,
      "star_num": star_num,
      "font_size": font_size,
      "font_color": font_color,
      "font_weight": font_weight,
      "supportList": supportList,
      "starList": starList,
    };
  }

  Post.fromDb(Map<String, dynamic> db):
    id = db['id'],
    userId = db['uid'].toString(),
    title = db['title'],
    nickname = db['nickname'],
    comments = jsonDecode(db['comments']),
    content = db['content'],
    last_replied_user_id = db['last_replied_user_id'] ?? '',
    last_replied_time = db['last_replied_time'] ?? '',
    created = db['created'],
    updated = db['updated'],
    type = db['type'] ?? 1,
    position = db['position'] ?? '',
    support_num = db['support_num'] ?? 0,
    comment_num = db['comment_num'] ?? 0,
    star_num = db['star_num'] ?? 0,
    font_size = db['font_size'] ?? 16,

    font_color = db['font_color'] ?? '#000000',
    font_weight = db['font_weight'] ?? 'normal',
    supportList= db['supportList'].split(','),
    starList= db['starList'].split(','),
    images = db["images"] !=[] ? db["images"].split(','): [],
    videos =db['videos'].split(',');

    Map<String, dynamic> toDbMap() => <String ,dynamic>{
      "id": id,
      "uid": userId,
      "title": title,
      "nickname":nickname,
      "comments": jsonEncode(comments),
      "content": content,
      "last_replied_user_id": last_replied_user_id,
      "last_replied_time": last_replied_time,
      "created": created,
      "updated": updated,
      "type": type,
      "position": position,
      "support_num": support_num,
      "comment_num": comment_num,
      "star_num": star_num,
      "font_size": font_size,
      "font_color": font_color,
      "font_weight": font_weight,
      "supportList": supportList.join(','),
      "starList": starList.join(','),
      "images": images !=[] ? images.join(','): [],
      "videos": videos.join(','),
    };


}
