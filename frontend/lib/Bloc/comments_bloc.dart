// TODO Implement this library.
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/post.dart';
import 'package:rxdart/rxdart.dart';
import '../resources/respository/comments_repository.dart';
import '../resources/respository/feeds_repository.dart';

class CommentsBloc {
  CommentsBloc() {
    _commentsFetcher.transform(_commentsTransFormer()).pipe(_commentsOutPut);
  }

  final _repository = CommentsRepository(); //一个NewsRepository对象，用于从网络或本地获取评论数据。
  final _commentsFetcher = PublishSubject<int>(); //一个PublishSubject，它用于向BLoC发送评论数据请求。
  final _commentsOutPut = BehaviorSubject<Map<int, Future<Comment>>>(); //一个BehaviorSubject对象，它用于订阅评论数据的异步流。

  //stream
  Stream<Map<int, Future<Comment>>> get itemWithComments =>
      _commentsOutPut.stream; //Getter方法，它返回一个Stream对象，用于监听评论数据的异步流。

  //sink
  Function(int) get fetchItemWithComments => _commentsFetcher.sink.add; //一个处理评论数据请求的方法，它会向_commentsFetcher发送一个评论ID，以获取该评论的详细信息。

  _commentsTransFormer() {  //一个私有方法，它返回一个ScanStreamTransformer对象，用于将评论数据转换为一个Map<int, Future<ItemModel>>对象，该对象包含每个评论的详细信息和它的子评论。
    //todo
    return ScanStreamTransformer(
            (Map<int, Future<Comment>> cache, int id, index) {
          cache[id] = _repository.getComment(id)
            ..then((Comment item) {
              // for (var comment in item.comments) {
              //   fetchItemWithComments(comment.id);
              // }
            });
      return cache;
    }, <int, Future<Comment>>{});
  }

  dispose() { //用于关闭_commentsFetcher和_commentsOutPut对象的流，以及释放与其相关的任何资源。
    _commentsFetcher.close();
    _commentsOutPut.close();
  }
}