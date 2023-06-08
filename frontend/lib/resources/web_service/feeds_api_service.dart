// TODO Implement this library.
import 'package:flutter/foundation.dart';
import 'package:frontend/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/post.dart';
import 'dart:async';
import '../../utils/global_variable.dart';
import '../interface/feeds_interface.dart';
import '../database_methods.dart' as db;
import 'api_service.dart';
import 'media_api_service.dart' as mediaApi;
const String url = "https://hacker-news.firebaseio.com/v0";

class FeedsApiService extends ApiService implements Source {
  http.Client client = http.Client();

  //获取头条新闻id
  @override
  Future<List<List<int>>> fetchIdsByRules([int page=1,int size=10,int userId=0, String? orderByWhat=null,int type=0, bool? onlyFollowing=null,
    bool? hot=null,bool? star= null]) async{
    // final response = await client.get("$url/top-stories.json" as Uri);
    if (kDebugMode) {
      print("NewsApiProvider fetchTopIds");
    }

    List<List<int>> list;

    list = await db.DataBaseManager().getNewPostList(page, size, userId, orderByWhat, type, onlyFollowing, hot,star);
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
    List<String>? imageUrls = await mediaApi.MediaApiService().getImageUrls(id);
    List<String>? videoUrls = await mediaApi.MediaApiService().getVideoUrls(id);
    print("THEcontent: $content");
    content?['images'] = imageUrls;
    content?['videos'] = videoUrls;
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

  @override
  Future<String> starPost(int postId, String uid,List stars,String title) async {
    // TODO: implement starPost
    print("starpost");
    print("starpost");
    print(uid);
    print(stars);
    String res = "Fail";
    List<String> temp = stars.map((dynamic) => dynamic.toString()).toList();
    if(temp.contains(uid)==false){
      print("not contain");
      res = await db.DataBaseManager().starPost(postId, uid,title);
      print(res);
      if(res == "Success"){
        stars.add(int.parse(uid));
        print(stars);
        return "Success";
      }
      else{
        print(stars);
        return "Error";
      }
    }
    else{
      print("contain");
      res = await db.DataBaseManager().cancelStar(postId, uid);
      print(res);
      if(res == "Success"){
        stars.remove(int.parse(uid));
        print(stars);
        return "Success";
      }
      else{
        print(stars);
        return "Error";
      }
    }
  }

  @override
  Future<String> supportPost(int postId, String uid, List supports) async {
    print("supportpost");
    print(uid);
    print(supports);
    String res = "Fail";
    print(supports.runtimeType);
    //print(supports[0].runtimeType);
    List<String> temp = supports.map((dynamic) => dynamic.toString()).toList();
    if(temp.contains(uid)==false){
      res = await db.DataBaseManager().supportPost(postId, 1);

      if(res == "Success"){
        supports.add(int.parse(uid));
        return "Success";
      }
      else{
        return "Error";
      }
    }
    else{
      res = await db.DataBaseManager().supportPost(postId, -1);
      if(res == "Success"){
        supports.remove(int.parse(uid));
        return "Fail";
      }
      else{
        return "Error";
      }
    }
  }

  @override
  Future<List<List<int>>> fetchIdsByKeyWords(String keywords) async {
    print("fetchIdsByKeyWords");
    String url = '/api/post/searchpost';
    Map<String,dynamic> result = await sendGetRequest(url, {'keywords': keywords}) as Map<String, dynamic>;
    List<int> newFeedIdList =[];
    List<int> feedCreatorIdList =[];
    for(var item in result['postList']){
      newFeedIdList.add(item['id']);
      feedCreatorIdList.add(item['user_id']);
    }
    return [newFeedIdList,feedCreatorIdList];
  }
}