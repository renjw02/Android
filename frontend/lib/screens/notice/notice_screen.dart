import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:frontend/screens/profile_screen.dart';
import '../../models/querySnapshot.dart';
import '../../resources/database_methods.dart' as db;
import '../../utils/global_variable.dart' as gv;

// For the testing purposes, you should probably use https://pub.dev/packages/uuid.
String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key, required this.snap,required this.file, this.content});
  final snap;
  final Uint8List file;
  final content;
  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  bool isLoading = false;
  late final Map<String,dynamic> userinfo;
  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final snap = widget.snap;
      // 输出 snap
      if (kDebugMode) {
        print('snap: $snap');
        print('userId: ${snap['userId']}');
      }

      final dbm = db.DataBaseManager();
      final userId = snap['userId'].toString();
      final url = Uri.parse('${gv.ip}/api/user/user/$userId');
      userinfo = await dbm.getSomeMap(url);
      // 输出 userinfo
      if (kDebugMode) {
        print('userinfo: $userinfo');
      }

      final content = await dbm.noticeContentQuery(snap['noticeId']);
      // 输出 content
      if (kDebugMode) {
        print('content: $content');
      }
    } catch (err) {
      // 处理异常
      if (kDebugMode) {
        print('Error: $err');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context){
    return isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    ):Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
                onTap:(){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(uid: widget.snap['userId'].toString()),
                    ),
                  );
                },
                child:CircleAvatar(
                  radius: 16,
                  backgroundImage: MemoryImage(widget.file),
                )
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userinfo['username'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body:Center(
        child: Text(
          widget.content.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}