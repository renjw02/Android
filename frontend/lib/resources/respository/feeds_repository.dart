// TODO Implement this library.
import 'package:flutter/foundation.dart';

import '../../models/post.dart';
import '../../models/user.dart';
import '../cache_service/feeds_cache_service.dart';
import '../web_service/feeds_api_service.dart';
import '../db_service/db_provider.dart';
import '../interface/feeds_interface.dart';

class FeedsRepository{
  final List<Source> _sourceList = [
    FeedsCacheService(),
    // dbProvider!.feedsDbProvider,
    FeedsApiService(),
  ];

  final List<Cache> _cacheList = [
    FeedsCacheService(),
    // dbProvider!.feedsDbProvider,
  ];

  //fetchTopIds from network
  Future<List<List<int>>> fetchTopIds() {
    return _sourceList[1].fetchIdsByRules();
  }
  //[int page=1,int size=10,int userId=0, String? orderByWhat=null,int type=0, bool? onlyFollowing=null,
  //     bool? hot=null]
  Future<List<List<int>>> fetchIdsByUserId(String uid) {
    return _sourceList[1].fetchIdsByRules(1, 10, int.parse(uid), null, 0, null, null);
  }

  //fetchIds By Rules
  Future<List<List<int>>> fetchIdsbyRules([int page=1,int size=10,int userId=0, String? orderByWhat = null,int type = 0, bool? onlyFollowing = null,
    bool? hot=null,bool? star= null]) {
    return _sourceList[1].fetchIdsByRules(page, size, userId, orderByWhat, type, onlyFollowing, hot, star);
  }

  Future<List<List<int>>> fetchIdsByKeyWords(String keywords) {
    return _sourceList[1].fetchIdsByKeyWords(keywords);
  }
  Future<User> fetchUser(int uid) async {
    if (kDebugMode) {
      print("NewsRepository fetchUser: $uid");
    }
    User? user;

    var source;
    for(source in _sourceList){
      print(source);
      user = await source.fetchUser(uid);
      if(user != null) break;
    }

    print("source.fetchUser(uid);");
    print(user);
    for(var cache in _cacheList){
      print(cache);
      if(cache != source) cache.addUser(user!);
    }
    return user!;
  }

  Future<Post> fetchItem(int id) async{
    if (kDebugMode) {
      print("NewsRepository fetchItem: $id");
    }
    Post? item;

    var source;
    for(source in _sourceList){
      print(source);
      item = await source.fetchItem(id);
      if(item != null) break;
    }

    print("source.fetchItem(id);");
    for(var cache in _cacheList){
      print(cache);
      if(cache != source) cache.addItem(item!);
    }
    return item!;
  }

  Future<String> supportPost(int postId, String uid, List supports) async {
    //todo
    String res = "Fail";
    try{
      List supportCopy = supports;
      //res = await _sourceList[0].supportPost(postId, uid, supportCopy);
      await _sourceList[1].supportPost(postId, uid, supports);
    }catch(e){
      print(e);
    }
    print("resposi"+supports.toString());
    return res;
  }

  Future<String> starPost(int postId, String uid,List stars,String title) async {
    //todo
    String res = "Fail";
    try{
      await _sourceList[1].starPost(postId, uid,stars,title);
      print("resposi"+stars.toString());
    }catch(e){
      print(e);
    }
    //res = await _sourceList[0].starPost(postId, title, title, stars);

    return res;
  }

  clearCache() async{
    for(var cache in _cacheList){
      await cache.clear();
    }
  }




}
