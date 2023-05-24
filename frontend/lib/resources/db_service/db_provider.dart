import 'comments_db_provider.dart';
import 'feeds_db_provider.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();

  factory DatabaseProvider() => _instance;

  DatabaseProvider._internal() {
    _init();
  }

  // todo: late UsersDbProvider userDbProvider;
  late FeedsDbProvider feedsDbProvider;
  late CommentsDbProvider commentsDbProvider;

  Future<void> _init() async {
    // todo:  userDbProvider = UsersDbProvider();
    feedsDbProvider = FeedsDbProvider();
    commentsDbProvider = CommentsDbProvider();
  }
}

DatabaseProvider? dbProvider;