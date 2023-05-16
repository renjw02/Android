import 'dart:ui';

import 'documentSnapshot.dart';

class Post {
  final int id;
  final String uid;
  final String title;
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
  List<dynamic> supportList;   //喜欢这个贴子的用户
  List<dynamic> starList;
  // final String username;
  // final likes;
  // final String postId;
  // final DateTime datePublished;
  // final String postUrl;
  // final String profImage;
  Post(
      {required this.id,
      required this.uid,
      required this.title,
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
      });

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


  data(){
    return {
      "id":id,
      "uid":uid,
      "title":title,
      "content":content,
      "last_replied_user_id":last_replied_user_id,
      "last_replied_time":last_replied_time,
      "created":created,
      "updated":updated,
      "type":type,
      "position":position,
      "support_num":support_num,
      "comment_num":comment_num,
      "star_num":star_num,
      "font_size":font_size,
      "font_color":font_color,
      "font_weight":font_weight,
      "supportList":supportList,
      "starList":starList,
    };
  }
   Map<String, dynamic> toJson() => {
       "id":id,
       "uid":uid,
       "title":title,
       "content":content,
       "last_replied_user_id":last_replied_user_id,
       "last_replied_time":last_replied_time,
       "created":created,
       "updated":updated,
       "type":type,
       "position":position,
       "support_num":support_num,
       "comment_num":comment_num,
       "star_num":star_num,
       "font_size":font_size,
       "font_color":font_color,
       "font_weight":font_weight,
       "supportList":supportList,
       "starList":starList,
      };
}
