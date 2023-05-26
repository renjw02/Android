// TODO Implement this library.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import '../../models/post.dart';
import '../interface/feeds_interface.dart';

const String _postTableName = "table_post";
const String _userTableName = "table_user";
const String _commentTableName = "table_comment";

class FeedsDbProvider implements Source, Cache {
  late Database _db;

  FeedsDbProvider() {
    if (kDebugMode) {
      print("FeedsDbProvider constructor");
    }
    init();
  }

  //初始化db
  init() async {
    if (kDebugMode) {
      print("FeedsDbProvider init");
    }
    Directory directory = await getApplicationDocumentsDirectory();
    if (kDebugMode) {
      print("FeedsDbProvider init directory: $directory");
    }
    String path = join(directory.path, "items.db");
    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) {
      db.execute('''
            CREATE TABLE IF NOT EXISTS $_postTableName (
              id INTEGER PRIMARY KEY,
              uid TEXT,
              title TEXT,
              nickname TEXT,
              comments TEXT,
              content TEXT,
              last_replied_user_id TEXT,
              last_replied_time TEXT, 
              created TEXT,
              updated TEXT,
              type INTEGER,
              position TEXT,
              support_num INTEGER,
              comment_num INTEGER,
              star_num INTEGER,
              font_size INTEGER,
              font_color TEXT,
              font_weight TEXT,
              supportList TEXT,
              starList TEXT,
              images TEXT,
              videos TEXT
            )
          ''');
      db.execute('''
            CREATE TABLE IF NOT EXISTS $_userTableName (
              email TEXT,
              password TEXT,
              uid INTEGER PRIMARY  TEXT,
              jwt TEXT, 
              photoUrl TEXT,
              photo BLOB,
              username TEXT,
              nickname TEXT,
              profile TEXT,
              followers TEXT,
              following TEXT
            )
          ''');
    });
    print("FeedsDbProvider init _db success: $_db");
  }

  @override
  Future<Post?> fetchItem(int id) async {
    if (kDebugMode) {
      print("FeedsDbProvider fetchItem: $id");
    }
    final itemMap = await _db.query(
      _postTableName,
      columns: null,
      where: "id = ?",
      whereArgs: [id],
    );
    if (kDebugMode) {
      print("FeedsDbProvider fetchItem itemMap: $itemMap");
    }
    if (itemMap.isNotEmpty) {
      return Post.fromDb(itemMap.first);
    }
    if (kDebugMode) {
      print("FeedsDbProvider fetchItem null");
    }
    return null;
  }

  @override
  Future<User?> fetchUser(int uid) async {
    if (kDebugMode) {
      print("FeedsDbProvider fetchUser: $uid");
    }
    final userMap = await _db.query(
      _userTableName,
      columns: null,
      where: "uid = ?",
      whereArgs: [uid],
    );
    if (kDebugMode) {
      print("FeedsDbProvider fetchUser userMap: $userMap");
    }
    if (userMap.isNotEmpty) {
      return User.fromDb(userMap.first);
    }
    if (kDebugMode) {
      print("FeedsDbProvider fetchUser null");
    }
  }

  //ConflictAlgorithm.ignore：当有重复的值被写入时忽略
  @override
  Future<int> addItem(Post item) {
    if (kDebugMode) {
      print("FeedsDbProvider addItem: $item");
    }
    return _db.insert(_postTableName, item.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  @override
  Future<int> addUser(User user) {
    if (kDebugMode) {
      print("FeedsDbProvider addUser: $user");
    }
    return _db.insert(_userTableName, user.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  void deleteItem(int id) async {
    if (kDebugMode) {
      print("FeedsDbProvider deleteItem: $id");
    }
    await _db.delete(_postTableName, where: "id = ?", whereArgs: [id]);
  }

  ////清理数据库
  @override
  Future<int> clear() {
    if (kDebugMode) {
      print("FeedsDbProvider clear");
    }
    return _db.delete(_postTableName);
  }

  @override
  Future<List<List<int>>> fetchIdsByRules([int page=1,int size=10,int userId=0, String? orderByWhat=null,int type=0, bool? onlyFollowing=null,
    bool? hot=null]) {
    if (kDebugMode) {
      print("FeedsDbProvider fetchTopIds");
    }
    throw UnimplementedError();
  }

  @override
  Future<String> starPost(int postId, String uid, String title, List stars) {
    // TODO: implement starPost
    throw UnimplementedError();
  }

  @override
  Future<String> supportPost(int postId, String uid, List supports) async {
    try {
      var now = DateTime.now();
      var supportsList = (await _db.query(
      "SELECT supports FROM posts WHERE id = ?", whereArgs: [postId]
      ))[0]['supports'] as List;
    if (supportsList!.contains(uid)) {
    return "already exist";
    }
    supportsList?.add(uid);
    await _db.rawUpdate(
    "UPDATE posts SET support_num = support_num + 1, supports = ?, updated = ? WHERE id = ?",
    [jsonEncode(supportsList), now, postId]
    );
    return 'ok';
    } catch (e) {
    print(e);
    // await _db.rollback();
    return 'errors';
    }
  }
}

