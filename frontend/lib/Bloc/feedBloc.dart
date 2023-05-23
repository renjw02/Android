

import 'dart:async';
import '../Auth/customAuth.dart';
import './bloc.dart';

import '../models/querySnapshot.dart';
import '../resources/database_methods.dart' as db;

class FeedsBloc implements Bloc {
  late QuerySnapshot _querySnapshot;
  QuerySnapshot get selectedQuery => _querySnapshot;

  // 1
  final _queryController = StreamController<QuerySnapshot>.broadcast();

  // 2
  Stream<QuerySnapshot> get queryStream => _queryController.stream.asBroadcastStream()!;

  FeedsBloc(String arg) {
    // queryStream = _queryController.stream.asBroadcastStream();
    print('Creating FeedsBloc object');
    print(arg);
    print('FeedsBloc object created');
    submitQuery();
  }

  // 3
  void selectQuery(QuerySnapshot querySnapshot) {
    _querySnapshot = querySnapshot;
    _queryController.sink.add(querySnapshot);
  }

  void submitQuery() async {
    print('Submitting query...');
    QuerySnapshot querySnapshot = await db.DataBaseManager().feedsQuery();
    _queryController.sink.add(querySnapshot);
    _querySnapshot = querySnapshot;
    print('Query submitted');
    // selectQuery(querySnapshot);
  }

  // 4
  @override
  void dispose() {
    print('Disposing FeedsBloc object');
    _queryController.close();
  }
}