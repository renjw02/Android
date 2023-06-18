import 'dart:async';
import './bloc.dart';

import '../models/querySnapshot.dart';
import '../resources/database_methods.dart' as db;

class ContactsBloc implements Bloc {
  late QuerySnapshot _querySnapshot;
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

  void submitQuery() async {
    QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();
    _queryController.sink.add(querySnapshot);
    // selectQuery(querySnapshot);
  }

  // 4
  @override
  void dispose() {
    _queryController.close();
  }
}