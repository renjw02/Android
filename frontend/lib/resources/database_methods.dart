//   TODO
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:frontend/Auth/customAuth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/user.dart';

class DataBaseManager{
  final http.Client _client = http.Client();
  // 登陆
  Future<dynamic> signIn(Uri url,String email,String password) async {
    Map<String, String> headersMap = new Map();
    headersMap["content-type"] = ContentType.json.toString();
    Map<String, String> bodyParams = new Map();
    bodyParams["username"] = email;
    bodyParams["password"] = password;
    var result="Fail";
    try{
      await _client.post(
          url,
          headers:headersMap,
          // body: bodyParams,
          body:jsonEncode({
            "username":email,
            "password":password,
          }),
          encoding: Utf8Codec()
      ).then((http.Response response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> returndata = jsonDecode(response.body);
          print(returndata);
          final data = {
            'username': returndata['username'],
            'uid': returndata['userId'].toString(),
            'jwt':returndata['jwt'],
            'photoUrl': 'photoUrl',
            'email': email,
            "password":password,
            'nickname': returndata['nickname'],
            'profile':'profile',
            'followers': [],
            'following': [],
          };
          CustomAuth.currentUser = User(
            username: data['username'] as String,
            password: data['password'] as String,
            uid: data['uid'] as String,
            jwt: data['jwt'] as String,
            photoUrl: data['photoUrl'] as String,
            email: data['email'] as String,
            nickname: data['nickname'] as String,
            profile:data['profile'] as String,
            followers: data['followers'] as List,
            following: data['following'] as List,
          );
          result = "Success";
        } else {
          print('error code');
        }
      }).catchError((error) {
        print(error);
        print('error 11');
      });
    }catch(e){
      print('second False');
    }
    return result;
  }
  //  使用ID获取指定user
  Future<Map<String, dynamic>> getSomeMap(Uri url,String jwt) async{
    Map<String, dynamic> info = {};
    await _client.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: jwt,
      },
    ).then((http.Response response) {
      //处理响应信息
      if (response.statusCode == 200) {
        info = jsonDecode(response.body);
      } else {
        print('error');
        print(response.body);
      }
    }).catchError((e){
      print(e);
    });
    return info;
  }
  // Future<Map<String, dynamic>> getFollowers(Uri url,String jwt) async{
  //   Map<String, dynamic> userFollowers = {};
  //   await _client.get(
  //     url,
  //     headers: {
  //       HttpHeaders.authorizationHeader: jwt,
  //     },
  //   ).then((http.Response response) {
  //     //处理响应信息
  //     if (response.statusCode == 200) {
  //       userFollowers = jsonDecode(response.body);
  //     } else {
  //       print('error');
  //       print(response.body);
  //     }
  //   }).catchError((e){
  //     print(e);
  //   });
  //   return userFollowers;
  // }
  // Future<Map<String, dynamic>> getFollowed(Uri url,String uid,String jwt) async{
  //   Map<String, dynamic> userFollowed = {};
  //   await _client.get(
  //     url,
  //     headers: {
  //       HttpHeaders.authorizationHeader: jwt,
  //     },
  //   ).then((http.Response response) {
  //     //处理响应信息
  //     if (response.statusCode == 200) {
  //       userFollowed = jsonDecode(response.body);
  //     } else {
  //       print('error');
  //       print(response.body);
  //     }
  //   }).catchError((e){
  //     print(e);
  //   });
  //   return userFollowed;
  // }
}