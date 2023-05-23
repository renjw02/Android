// TODO Implement this library.
import 'package:flutter/foundation.dart';
import 'package:frontend/models/querySnapshot.dart';
import 'package:frontend/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post.dart';
import 'dart:async';
import '../utils/global_variable.dart';
import './feeds_interface.dart';
import 'database_methods.dart' as db;
const String url = "https://hacker-news.firebaseio.com/v0";

class FeedsApiProvider implements Source{
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
    await Future.delayed(const Duration(milliseconds: 50));
    //在从本地的读取top-stories的json字典的数据代替从客户端获取数据
    // const topStories = "[1, 2]";
    List<List<int>> list;


    list = await db.DataBaseManager().getNewPostList();
    print("list<int>");
    print(list);
    print("list<int>");
    return list;
  }

  //根据id获取头条新闻内容
  @override
  Future<Post?> fetchItem(int id)async{
    // final response = await client.get("$url/item/$id.json" as Uri);
    if (kDebugMode) {
      print("NewsApiProvider fetchItem: $id");
    }
    //content是Map<String, dynamic>类型
    Map<String, dynamic>? content = await db.DataBaseManager().getThePost(id);
    List<String>? imageUrls = await db.DataBaseManager().getImageUrls(id);
    print("THEcontent: $content");
    content?['images'] = imageUrls;
    print("content: $content");
    return Post.fromJson(content!);
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
}