import 'package:flutter/foundation.dart';
import 'package:frontend/models/user.dart';

import './api_service.dart' ;
import '../../models/comment.dart';
import '../interface/comments_interface.dart';
class CommentApiService extends ApiService implements Source {
  Future<String> createComment(int postId, String content, [int commentId = 0]) async {
    String url = '/api/post/createcomment/$postId';
    final body = {
      'content': content,
      'commentId': commentId,
    } ;
    if (kDebugMode) {
      print('createComment: $url');
    }
    var result = await sendPostRequest(url, body);
    if (kDebugMode) {
      print('createComment: $result');
      print(result);
    }
    return result;
  }

  Future<Comment> getComment(int commentId) async {
    String url = '/api/post/getcomment/$commentId';
    if (kDebugMode) {
      print('getComment: $url');
    }
    var result = await sendGetRequest(url, {});
    if (kDebugMode) {
      print('getComment: $result');
      print(result);
    }
    return Comment.fromJson(result);
  }

}
