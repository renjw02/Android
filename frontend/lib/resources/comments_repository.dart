// TODO Implement this library.
import 'package:flutter/foundation.dart';
import 'package:frontend/models/comment.dart';

import '../models/post.dart';
import '../models/user.dart';
import './feeds_api_provider.dart';
import './feeds_db_provider.dart';
import './feeds_interface.dart';

class CommentsRepository{
  final List<Source> _sourceList = [
    dbProvider!,
    FeedsApiProvider(),
  ];

  final List<Cache> _cacheList = [
    dbProvider!
  ];

  //fetchTopIds from network
  Future<List<List<int>>> fetchTopIds() => _sourceList[1].fetchTopIds();
  Future<User> fetchUser(int uid) async {
    if (kDebugMode) {
      print("CommentsRepository fetchUser: $uid");
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
  Future<Comment> fetchItem(int id) async{
    if (kDebugMode) {
      print("CommentsRepository fetchItem: $id");
    }
    Comment? item;

    var source;
    for(source in _sourceList){
      print(source);
      item = await source.fetchItem(id);
      if(item != null) break;
    }

    print("source.fetchItem(id);");
    for(var cache in _cacheList){
      print(cache);
      // if(cache != source) cache.addItem(item!);
    }
    return item!;
  }

  clearCache() async{
    for(var cache in _cacheList){
      await cache.clear();
    }
  }


}
