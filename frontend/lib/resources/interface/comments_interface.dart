// TODO Implement this library.
// import '../models/item_model.dart';

import 'package:frontend/models/user.dart';

import '../../models/comment.dart';

abstract class Source{
  Future<String> createComment(int postId, String content, [int commentId = 0]);
  Future<Comment> getComment(int commentId);
}

abstract class Cache{
  clear();
  Future<int> addItem(Comment item);
}