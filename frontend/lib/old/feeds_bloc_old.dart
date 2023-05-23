// TODO Implement this library.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../resources/repository.dart';
import '../utils/global_variable.dart';



class FeedsBloc {

  late final _newFilter;

  FeedsBloc(FeedsFilter filter) {
    if (kDebugMode) {
      print("FeedsBloc constructor");
    }
    _newFilter = filter;
    _itemsFetcher.transform(_itemTransformer()).pipe(_itemOutput);
    _userFetcher.transform(_userTransformer()).pipe(_userOutput);
  }

  final _repository = FeedsRepository(); //一个FeedsRepository对象，用于从网络或本地获取新闻数据。
  final _topIds = PublishSubject<List<int>>();
  final _itemsFetcher =  PublishSubject<int>(); //一个PublishSubject，它用于向BLoC发送新闻数据请求。
  final _itemOutput = BehaviorSubject<Map<int, Future<Post>>>(); //一个BehaviorSubject对象，它用于订阅新闻数据的异步流。

  final _userIds = PublishSubject<List<int>>();
  final _userFetcher = PublishSubject<int>();
  final _userOutput = BehaviorSubject<Map<int, Future<User>>>();

  //stream
  Stream<Map<int, Future<Post>>> get items => _itemOutput.stream;
  Stream<List<int>> get topIds {
    return _topIds.stream;
  }
  Stream<Map<int, Future<User>>> get users => _userOutput.stream;
  Stream<List<int>> get userIds {
    return _userIds.stream;
  }

  //sink
  Function(int) get fetchItems => _itemsFetcher.sink.add;
  Function(int) get fetchUsers => _userFetcher.sink.add;

  fetchTopIds() async {
    /// all, top, hot, follow, other
    final feedAndUserIds = await _repository.fetchTopIds();
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

  _userTransformer() {
    return ScanStreamTransformer(
            (Map<int, Future<User>> cache, int uid, _) {
          cache[uid] = _repository.fetchUser(uid);
          print("cache: $cache");
          return cache;
        }, <int, Future<User>>{});
  }

  dispose() {
    print("FeedsBloc dispose");
    _topIds.close();
    _userIds.close();
    _itemsFetcher.close();
    _userFetcher.close();
    _itemOutput.close();
    _userOutput.close();
  }
}