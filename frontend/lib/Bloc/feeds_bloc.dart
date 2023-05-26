// TODO Implement this library.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../resources/respository/feeds_repository.dart';
import '../utils/global_variable.dart';



class FeedsBloc {

  late final newFilter;

  FeedsBloc(FeedsFilter filter) {
    if (kDebugMode) {
      print("FeedsBloc constructor");
    }
    newFilter = filter;
    _itemsFetcher.transform(_itemTransformer()).pipe(_itemOutput);
  }

  final _repository = FeedsRepository(); //一个FeedsRepository对象，用于从网络或本地获取新闻数据。
  final _topIds = PublishSubject<List<int>>();
  final _itemsFetcher =  PublishSubject<int>(); //一个PublishSubject，它用于向BLoC发送新闻数据请求。
  final _itemOutput = BehaviorSubject<Map<int, Future<Post>>>(); //一个BehaviorSubject对象，它用于订阅新闻数据的异步流。

  final _userIds = PublishSubject<List<int>>();

  //stream
  Stream<Map<int, Future<Post>>> get items => _itemOutput.stream;
  Stream<List<int>> get topIds {
    return _topIds.stream;
  }
  Stream<List<int>> get userIds {
    return _userIds.stream;
  }

  //sink
  Function(int) get fetchItems {
    return _itemsFetcher.sink.add;
  }

  // Function(int postId, String uid, List supports) get supportPost {
  //
  // }
  Future<String> supportPost(int postId, String uid, List supports) async {
    String res = "Fail";
    print("FeedsBloc supportPost");
    print(res);
    res = await _repository.supportPost(postId, uid, supports);
    print(res);
    //稍等50ms
    // await Future.delayed(Duration(milliseconds: 50));
    _itemsFetcher.sink.add(postId);
    print(res);
    return res;
  }

  fetchTopIds() async {
    /// all, top, hot, follow, other
    final feedAndUserIds = await _repository.fetchTopIds();

    _topIds.sink.add(feedAndUserIds[0]);
    _userIds.sink.add(feedAndUserIds[1]);
  }

  fetchIdsByUserId(String uid) async {
    final feedAndUserIds = await _repository.fetchIdsByUserId(uid);

    _topIds.sink.add(feedAndUserIds[0]);
    _userIds.sink.add(feedAndUserIds[1]);
  }

  fetchIdsByRules([int page=1,int size=10,int userId=0, String? orderByWhat = null,int type = 0, bool? onlyFollowing = null,
  bool? hot=null]) async {
    final feedAndUserIds = await _repository.fetchIdsbyRules(page, size, userId, orderByWhat, type, onlyFollowing, hot);

    _topIds.sink.add(feedAndUserIds[0]);
    _userIds.sink.add(feedAndUserIds[1]);
  }

  clearCache ()=> _repository.clearCache();

  _itemTransformer() {
    return ScanStreamTransformer(
            (Map<int, Future<Post>> cache, int id, _) {
          cache[id] = _repository.fetchItem(id);
          return cache;
        }, <int, Future<Post>>{});
  }


  dispose() {
    print("FeedsBloc dispose");
    _topIds.close();
    _itemsFetcher.close();
    _itemOutput.close();
  }
}