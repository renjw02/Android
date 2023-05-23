// TODO Implement this library.
// import '../models/item_model.dart';

import 'package:frontend/models/user.dart';

import '../models/post.dart';

abstract class Source{
  Future<List<List<int>>> fetchTopIds();
  Future<dynamic> fetchItem(int id);
  Future<User?> fetchUser(int id);
}

abstract class Cache{
  clear();
  Future<int> addItem(Post item);

  Future<int> addUser(User user);
}