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
    print('createComment: $url');
    var result = await sendPostRequest(url, body);
    print('createComment: $result');
    print(result);
    return result;
  }

  Future<Comment> getComment(int commentId) async {
    String url = '/api/post/getcomment/$commentId';
    print('getComment: $url');
    var result = await sendGetRequest(url, {});
    print('getComment: $result');
    print(result);
    return Comment.fromJson(result);
  }

}
