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
  Future<List<List<int>>> fetchTopIds() => _sourceList[1].fetchTopIds();

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
      _sourceList[1].supportPost(postId, uid, supports);
      res = await _sourceList[0].supportPost(postId, uid, supports);
    }catch(e){
      print(e);
    }
    return res;
  }

  Future<String> starPost(int postId, String uid, String title,List stars) async {
    //todo
    String res = "Fail";
    _sourceList[1].starPost(postId, uid, title,stars);
    res = await _sourceList[0].starPost(postId, title, title, stars);
    return res;
  }

  clearCache() async{
    for(var cache in _cacheList){
      await cache.clear();
    }
  }


}
