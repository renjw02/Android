// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as int,
      userId: json['userId'].toString(),
      title: json['title'] as String,
      nickname: json['nickname'] as String,
      comments: json['comments'] == [] ? []: json['comments'],
      content: json['content'] as String,
      last_replied_user_id: json['lastRepliedUserId'] ?? '' as String,
      last_replied_time: json['lastRepliedTime'] ?? '' as String,
      created: json['created'] as String,
      updated: json['updated'] as String,
      type: json['type'] ?? 1 as int,
      position: json['position'] ?? '' as String,
      support_num: json['supportNum']  ?? 0 as int,
      comment_num: json['commentNum']  ?? 0 as int,
      star_num: json['starNum']  ?? 0 as int,
      font_size: json['fontSize']  ?? 0 as int,
      font_color: json['fontColor']  ?? '' as String,
      font_weight: json['fontWeight'] ?? ''  as String,
      supportList: json['supportList']  ?? [""] as List<String>,
      starList: json['starList']  ?? [""] as List<String>,
      images: json['images']  as List<String>,
      videos: json['videos']  ?? [""] as List<String>,
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'nickname': instance.nickname,
      'comments': instance.comments,
      'content': instance.content,
      'last_replied_user_id': instance.last_replied_user_id,
      'last_replied_time': instance.last_replied_time,
      'created': instance.created,
      'updated': instance.updated,
      'type': instance.type,
      'position': instance.position,
      'support_num': instance.support_num,
      'comment_num': instance.comment_num,
      'star_num': instance.star_num,
      'font_size': instance.font_size,
      'font_color': instance.font_color,
      'font_weight': instance.font_weight,
      'supportList': instance.supportList,
      'starList': instance.starList,
      'images': instance.images,
      'videos': instance.videos,
    };
