// TODO Implement this library.
// import '../models/item_model.dart';

import 'package:frontend/models/user.dart';

import '../../models/post.dart';

abstract class Source{
  Future<List<List<int>>> fetchIdsByRules([int page=1,int size=10,int userId=0, String? orderByWhat = null,int type = 0, bool? onlyFollowing = null,
    bool? hot=null]);
  Future<dynamic> fetchItem(int id);
  Future<User?> fetchUser(int id);
  Future<String> supportPost(int postId, String uid, List supports);
  Future<String> starPost(int postId, String uid, String title,List stars);
}

abstract class Cache{
  clear();
  Future<int> addItem(Post item);

  Future<int> addUser(User user);
}