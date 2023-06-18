// TODO Implement this library.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/models/user.dart';
import 'dart:async';
import '../../models/post.dart';
import '../../models/star.dart';
import '../interface/feeds_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedsCacheService implements Source, Cache {
  static late SharedPreferences _prefs;

  static void init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<int> addItem(Post item) async {
    var list = _prefs.getStringList('post_list') ?? [];
    print("addposts");

    int index = list.indexWhere((element) =>
    jsonDecode(element)['id'] == item.id);
    print("index");
    print(index);
    if (index != -1) {
      print("list[index]${list[index]}");
      print(item.toJson());
      list[index] = jsonEncode(item.toJson());
    } else {
      print(item.toJson());
      list.add(jsonEncode(item.toJson()));

    }
    await _prefs.setStringList('post_list', list);
    return item.id;
  }

  @override
  Future<int> addUser(User user) async {
    // TODO: 实现添加User到shared_preferences
    var list = _prefs.getStringList('user_list') ?? [];
    int index = list.indexWhere((element) =>
    jsonDecode(element)['uid'] == user.uid);
    if (index != -1) {
      list[index] = jsonEncode(user.toJson());
    } else {
      list.add(jsonEncode(user.toJson()));
    }
    await _prefs.setStringList('user_list', list);
    return int.parse(user.uid);
  }

  @override
  clear() async {
    if (kDebugMode) {
      print("cache clear");
    }
    await _prefs.remove('post_list');
    await _prefs.remove('user_list');
    //检测是否清除成功
    if (kDebugMode) {
      print('post_list');
    }
    var list = _prefs.getStringList('post_list');
    if (kDebugMode) {
      print(list);
    }

  }

  @override
  Future<Post?> fetchItem(int id) async {
    print("feedsCache fetchItem");
    var list = _prefs.getStringList('post_list');
    Post res;
    try{
      if (list != null) {
        var posts = list.map((e) => Post.fromJson(jsonDecode(e))).toList();
        print("posts");
        print(posts);
        for(var post in posts){
          print(post.id);
          print(post.comment_num);
        }
        for(var post in posts){
          print(post.toJson());
        }
        res = posts.firstWhere((post) => post.id == id);
      }else{
        return null;
      }
      return res;
    }catch(e){
      print(e);
      return null;
    }
  }

  @override
  Future<List<List<int>>> fetchIdsByRules([int page=1,int size=10,int userId=0, String? orderByWhat=null,int type=0, bool? onlyFollowing=null,
    bool? hot=null,bool? star= null]) {
    // TODO: implement fetchTopIds
    throw UnimplementedError();
  }

  @override
  Future<User?> fetchUser(int id) async {
    var list = _prefs.getStringList('post_list');
    User? res;
    if (list != null) {
      var users = list.map((e) => User.fromJson(jsonDecode(e))).toList();
      res = users.firstWhere((users) => users.uid == id.toString());
    }
    return res;
  }

  @override
  Future<String> starPost(int postId, String uid, List stars,String title) async {

    String res = "Fail";
    if(stars.contains(uid)==false){
      // res = await db.DataBaseManager().starPost(postId, uid,title);
      //1. 检查用户是否已收藏该帖子,如果收藏过直接返回
      //2. 创建Star记录,增加帖子收藏数,提交数据库事务
      //3. 返回Star记录和成功标识
      var list = _prefs.getStringList('post_list');
      if(list != null){
        var posts = list.map((e) => Post.fromJson(jsonDecode(e))).toList();
        var post = posts.firstWhere((post) => post.id == postId);
        post.star_num += 1;
        post.starList.add(uid);
        await _prefs.setStringList('post_list', list);
        stars.add(uid);
        return "Success";
      }else{
        return "Error";
      }
    }
    else{
      // res = await db.DataBaseManager().cancelStar(postId, uid);
      //1. 删除Star记录,减少帖子收藏数
      //2. 提交数据库事务
      //3. 返回成功标识
      var list = _prefs.getStringList('post_list');
      if(list != null){
        var posts = list.map((e) => Post.fromJson(jsonDecode(e))).toList();
        var post = posts.firstWhere((post) => post.id == postId);
        post.star_num -= 1;
        post.starList.remove(uid);
        await _prefs.setStringList('post_list', list);
        stars.remove(uid);
        return "Success";
      }
      else{
        return "Error";
      }

    }
  }

  @override
  Future<String> supportPost(int postId, String uid, List supports) async {
    print("feedsCache supportPost");
    print(uid);
    supports = supports.map((e) => e.toString()).toList();
    print(supports);
    print(supports.contains(uid));
    if(supports.contains(uid)==false){
      // res = await db.DataBaseManager().supportPost(postId, 1);
      // 找到对应的post，将其support_num+1,并将uid加入support_list
      var list = _prefs.getStringList('post_list');
      if(list != null){
        var posts = list.map((e) => Post.fromJson(jsonDecode(e))).toList();
        var post = posts.firstWhere((post) => post.id == postId);
        supports.add(uid);
        post.supportList = supports;
        post.support_num = post.supportList.length;
        print(post.toJson());
        list[list.indexWhere((e) => Post.fromJson(jsonDecode(e)).id == postId)] =
            jsonEncode(post);
        await _prefs.setStringList('post_list', list);
        supports.add(uid);
        return "Success";
      }else{
        return "Error";
      }
    }
    else{
      // res = await db.DataBaseManager().supportPost(postId, -1);
      var list = _prefs.getStringList('post_list');
      if(list != null){
        var posts = list.map((e) => Post.fromJson(jsonDecode(e))).toList();
        var post = posts.firstWhere((post) => post.id == postId);
        supports.remove(uid);
        post.supportList = supports;
        post.support_num = post.supportList.length;
        list[list.indexWhere((e) => Post.fromJson(jsonDecode(e)).id == postId)] =
            jsonEncode(post);
        await _prefs.setStringList('post_list', list);
        supports.remove(uid);
        return "Fail";
      }else{
        return "Error";
      }
    }
  }

  @override
  Future<List<List<int>>> fetchIdsByKeyWords(String keywords) {
    // TODO: implement fetchIdsByKeyWords
    throw UnimplementedError();
  }

}

