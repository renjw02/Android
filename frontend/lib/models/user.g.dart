// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      username: json['username'] as String,
      uid: json['id'].toString(),
      jwt: json['jwt'] ?? '' as String ?? '',
      photoUrl: json['photoUrl'] ?? ''  as String,
      photo: const Uint8ListConverter().fromJson(json['photo'] ?? [0] as List<int>),
      email: json['email'] ?? '' as String,
      password: json['password'] ?? '' as String,
      nickname: json['nickname'] ?? '' as String,
      profile: json['profile'] ?? '' as String,
      followers: json['followers'] ?? [] as List<dynamic>,
      following: json['following'] ?? [] as List<dynamic>,
      blockList: json['blockList'] ?? [] as List<dynamic>,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'uid': instance.uid,
      'jwt': instance.jwt,
      'photoUrl': instance.photoUrl,
      'photo': const Uint8ListConverter().toJson(instance.photo),
      'username': instance.username,
      'nickname': instance.nickname,
      'profile': instance.profile,
      'followers': instance.followers,
      'following': instance.following,
      'blockList': instance.blockList,
    };
