// TODO Implement this library.
import 'package:flutter/foundation.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/resources/web_service/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../utils/global_variable.dart';
import '../interface/comments_interface.dart';
import '../database_methods.dart' as db;
import '../../models/comment.dart';
const String url = "https://hacker-news.firebaseio.com/v0";

class CommentsApiProvider extends ApiService implements Source {
  http.Client client = http.Client();

  //获取头条新闻id
  @override
  Future<List<List<int>>> fetchTopIds([int page=1,int size=10,int userId=0, String? orderByWhat=null,int type=0, bool? onlyFollowing=null,
    bool? hot=null]) async{
    // final response = await client.get("$url/top-stories.json" as Uri);
    if (kDebugMode) {
      print("NewsApiProvider fetchTopIds");
    }
    //先等待0.05秒，模拟网络延迟
    List<List<int>> list;


    list = await db.DataBaseManager().getNewPostList();
    print("list<int>");
    print(list);
    print("list<int>");
    return list;
  }

  //根据id获取头条新闻内容
  @override
  Future<Comment> fetchItem(int commentId)async{
    String url = '/api/post/getcomment/$commentId';
    print('getComment: $url');
    var result = await sendGetRequest(url, {});
    print('getComment: $result');
    print(result);
    return Comment.fromJson(result);
  }

  @override
  Future<User?> fetchUser(int id) async {
    // TODO: implement fetchUser
    // throw UnimplementedError();
    var url = Uri.parse("$ip/api/user/user/$id");
    Map<String, dynamic> userinfo={};//获取用户信息
    userinfo = await db.DataBaseManager().getSomeMap(url);
    //获取用户头像,存入数据库
    print("fetchUser:$id");
    print("userinfo: $userinfo");
    return User.fromJson(userinfo);
  }

  @override
  Future<String> createComment(int postId, String content, [int commentId = 0]) {
    // TODO: implement createComment
    throw UnimplementedError();
  }

  @override
  Future<Comment> getComment(int commentId) async {
    String url = '/api/post/getcomment/$commentId';
    print('getComment: $url');
    var result = await sendGetRequest(url, {});
    print('getComment: $result');
    print(result);
    return Comment.fromJson(result);
  }
}