

import 'dart:async';
import '../Auth/customAuth.dart';
import './bloc.dart';

import '../models/querySnapshot.dart';
import '../resources/database_methods.dart' as db;

class NoticesBloc implements Bloc {
  late QuerySnapshot _querySnapshot;
  late String _type;
  QuerySnapshot get selectedQuery => _querySnapshot;

  // 1
  final _queryController = StreamController<QuerySnapshot>();

  // 2
  Stream<QuerySnapshot> get queryStream => _queryController.stream;

  // 3
  void selectQuery(QuerySnapshot querySnapshot) {
    _querySnapshot = querySnapshot;
    _queryController.sink.add(querySnapshot);
  }

  Future<String> removeNotice(int noticeId) async {
    print("removeNotice");
    String result = await db.DataBaseManager().removeNotice(noticeId);
    if(result == "Success"){
      submitQuery(_type);
      print("删除成功");
    }else{
      print("删除失败");
    }
    return result;
  }

  Future<String> createNotice(String str_type, String content) async  {
    int type = 0;
    if (str_type == "通知" || str_type == "全部") {
      type = 0;
    } else if (str_type == "私信") {
      type = 1;
    } else if (str_type == "已认证") {
      type = 2;
    } else if (str_type == "提及") {
      type = 3;
    } else {
      type = 4;
    }
    String returnMsg = await db.DataBaseManager().createNotice(type, content);
    if(returnMsg == "Success"){
      submitQuery(_type);
      print("创建成功");
    }else{
      print("创建失败");
    }

    return returnMsg;

    // _queryController.sink.add(querySnapshot);
  }
  void submitQuery(String type) async {
    //type的值可能是“全部”、“通知”、“私信”或非法值
    //根据type的值选择不同的查询
    switch (type) {
      case "全部":
        {
          QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();

          _queryController.sink.add(querySnapshot);
          break;
        }
      case "通知":
        {
          QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();
          //筛选出通知
          querySnapshot.docs = querySnapshot.docs.where((element) => element.data()['noticeType'] == 0).toList();
          _queryController.sink.add(querySnapshot);
          break;
        }
      case "私信":
        {
          QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();
          //筛选出私信
          querySnapshot.docs = querySnapshot.docs.where((element) => element.data()['noticeType'] == 1).toList();
          _queryController.sink.add(querySnapshot);
          break;
        }
      case "已认证":
        {
        QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();
        //筛选出已认证
        querySnapshot.docs = querySnapshot.docs.where((element) => element.data()['noticeType'] == 2).toList();
        _queryController.sink.add(querySnapshot);
        break;
        }
      case "提及":
        {
        QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();
        //筛选出提及
        querySnapshot.docs = querySnapshot.docs.where((element) => element.data()['noticeType'] == 3).toList();
        _queryController.sink.add(querySnapshot);
        break;
        }
      default:
        {
          print("非法值");
          return;
        }
    }
    _type = type;
  }

  // 4
  @override
  void dispose() {
    _queryController.close();
  }
}