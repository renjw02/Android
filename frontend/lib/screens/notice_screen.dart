import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:frontend/screens/profile_screen.dart';
import '../models/querySnapshot.dart';
import '../resources/database_methods.dart' as db;
import '../utils/global_variable.dart' as gv;

// For the testing purposes, you should probably use https://pub.dev/packages/uuid.
String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key, required this.snap,required this.file});
  final snap;
  final Uint8List file;
  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  bool isLoading = false;
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  late final Map<String,dynamic> userinfo;
  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    super.initState();
    getData();
  }
  getData() async {
    try {
      var snap = widget.snap;
      //输出snap
      print("snap");
      print(snap);
      print(snap['userId']);
      db.DataBaseManager dbm = db.DataBaseManager();
      String userId = snap['userId'].toString();
      var url = Uri.parse("${gv.ip}/api/user/user/$userId");
      userinfo = await dbm.getSomeMap(url);
      print("userinfo");

      String content = await dbm.noticeContentQuery(snap['noticeId']);
      print("content");
      print(content);

    } catch (err) {
      // showSnackBar(
      //   context,
      //   err.toString(),
      // );
      print(err);
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
                  backgroundImage: MemoryImage(widget.file!),
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
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
      ),
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
  }
}