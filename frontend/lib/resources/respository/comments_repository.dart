// TODO Implement this library.
import 'package:frontend/models/comment.dart';
import 'package:frontend/resources/db_service/db_provider.dart';

import '../web_service/comment_api_service.dart';
import '../interface/comments_interface.dart';

class CommentsRepository{
  final List<Source> _sourceList = [
    dbProvider!.commentsDbProvider,
    CommentApiService(),
  ];

  final List<Cache> _cacheList = [
    dbProvider!.commentsDbProvider,
  ];

  Future<String> createComment(int postId, String content, [int commentId = 0]) {
    // TODO: implement createComment
    throw UnimplementedError();
  }

  Future<Comment> getComment(int commentId) {
    // TODO: implement getComment
    throw UnimplementedError();
  }

  clearCache() async{
    for(var cache in _cacheList){
      await cache.clear();
    }
  }


}
