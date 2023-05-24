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
      supportList: json['supportList'] ?? [],
      starList: json['starList'] ?? [] ,
      images: json['images'] ?? [],
      videos: json['videos'] ?? [],
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'nickname': instance.nickname,
      'comments': instance.comments,
      'content': instance.content,
      'lastRepliedUserId': instance.last_replied_user_id,
      'lastRepliedTime': instance.last_replied_time,
      'created': instance.created,
      'updated': instance.updated,
      'type': instance.type,
      'position': instance.position,
      'supportNum': instance.support_num,
      'commentNum': instance.comment_num,
      'starNum': instance.star_num,
      'fontSize': instance.font_size,
      'fontColor': instance.font_color,
      'fontWeight': instance.font_weight,
      'supportList': instance.supportList,
      'starList': instance.starList,
      'images': instance.images,
      'videos': instance.videos,
    };
