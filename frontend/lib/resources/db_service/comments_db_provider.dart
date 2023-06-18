// TODO Implement this library.
import 'package:flutter/foundation.dart';
import 'package:frontend/models/comment.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import '../interface/comments_interface.dart';

const String _commentTableName = "table_comment";

class CommentsDbProvider implements Source, Cache {
  late Database _db;

  CommentsDbProvider() {
    if (kDebugMode) {
      print("CommentsDbProvider constructor");
    }
    init();
  }

  //初始化db
  init() async {
    if (kDebugMode) {
      print("CommentsDbProvider init");
    }
    Directory directory = await getApplicationDocumentsDirectory();
    if (kDebugMode) {
      print("CommentsDbProvider init directory: $directory");
    }
    String path = join(directory.path, "comments_items.db");
    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) {
      db.execute('''
            CREATE TABLE IF NOT EXISTS $_commentTableName (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        post_id INTEGER NOT NULL,
        comment_id INTEGER,
        content TEXT NOT NULL,
        created DATETIME NOT NULL,
        updated DATETIME NOT NULL,
    );
          ''');
    });
    print("CommentsDbProvider init _db success: $_db");
  }

  //ConflictAlgorithm.ignore：当有重复的值被写入时忽略
  @override
  Future<int> addItem(Comment item) {
    if (kDebugMode) {
      print("CommentsDbProvider addItem: $item");
    }
    return _db.insert(_commentTableName, item.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  void deleteItem(int id) async {
    if (kDebugMode) {
      print("CommentsDbProvider deleteItem: $id");
    }
    await _db.delete(_commentTableName, where: "id = ?", whereArgs: [id]);
  }

  ////清理数据库
  @override
  Future<int> clear() {
    if (kDebugMode) {
      print("CommentsDbProvider clear");
    }
    return _db.delete(_commentTableName);
  }


  @override
  Future<String> createComment(int postId, String content, [int commentId = 0]) {
    // TODO: implement createComment
    throw UnimplementedError();
  }

  @override
  Future<Comment> getComment(int commentId) {
    // TODO: implement getComment
    throw UnimplementedError();
  }
}
