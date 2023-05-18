import 'dart:async';

import '../models/querySnapshot.dart';
import '../resources/database_methods.dart' as db;
import './bloc.dart';

class MessageBloc implements Bloc {
  late QuerySnapshot _querySnapshot;
  QuerySnapshot get selectedQuery => _querySnapshot;

  final _queryController = StreamController<QuerySnapshot>();
  Stream<QuerySnapshot> get queryStream => _queryController.stream;

  void selectQuery(QuerySnapshot querySnapshot) {
    _querySnapshot = querySnapshot;
    _queryController.sink.add(querySnapshot);
  }

  Future<String> sendMessage(int senderId, int receiverId, String content) async {
    String returnMsg = await db.DataBaseManager().createMessage(senderId, receiverId, content);
    if (returnMsg == "Success") {
      submitQuery();
      print("发送私信成功");
    } else {
      print("发送私信失败");
    }
    return returnMsg;
  }

  Future<QuerySnapshot> getChatHistory(int senderId, int receiverId) async {
    QuerySnapshot querySnapshot = await db.DataBaseManager().getChatHistory(senderId, receiverId);
    _queryController.sink.add(querySnapshot);
    return querySnapshot;
  }

  Future<Map<String, dynamic>?> getMessageContent(int messageId) async {
    Map<String, dynamic>? messageContent = await db.DataBaseManager().getMessageContent(messageId);
    return messageContent;
  }

  void submitQuery() async {
    QuerySnapshot querySnapshot = await db.DataBaseManager().messageListQuery();
    _queryController.sink.add(querySnapshot);
  }

  @override
  void dispose() {
    _queryController.close();
  }
}