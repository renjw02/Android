import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:frontend/screens/profile_screen.dart';
import '../../models/querySnapshot.dart';
import '../../resources/database_methods.dart' as db;
import '../../utils/global_variable.dart' as gv;
import '../../models/message.dart' as msg;
// For the testing purposes, you should probably use https://pub.dev/packages/uuid.
String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.file, this.user, this.opuser});
  final Uint8List file;
  final user; //当前用户
  final opuser;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isLoading = false;
  final List<types.Message> _messages = [];
  late final _user; //当前用户
  late final _opuser;
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
      _user= types.User(id:widget.user );
      _opuser= types.User(id:widget.opuser);
      print("user");
      print(widget.user);
      print("opuser");
      print(widget.opuser);
      db.DataBaseManager dbm = db.DataBaseManager();
      // String opuserName = snap['noticeCreator'].toString();
      var url = Uri.parse("${gv.ip}/api/user/user/${widget.opuser}");
      userinfo = await dbm.getSomeMap(url);
      print("userinfo");

      // String content = await dbm.noticeContentQuery(snap['noticeId']);
      // widget.snap["hasChecked"] = 1;
      // print("content");
      // print(content);

      var senderId = int.parse(widget.opuser);
      var receiverId =  int.parse(widget.user);
      QuerySnapshot querySnapshot = await dbm.getChatHistory(senderId, receiverId);
      print("querySnapshot");
      print(querySnapshot.docs);
      refresh(querySnapshot, senderId, receiverId);
    } catch (err) {
      print("err");
      print(err);
    }
    setState(() {
      isLoading = false;
    });
  }

  void refresh(QuerySnapshot querySnapshot,int senderId,int receiverId) async {
    querySnapshot.docs= querySnapshot.docs.map((message) {
      var authorId = message.senderId;
      if (authorId == senderId) {
        return types.TextMessage(
          author: _opuser,
          createdAt: message.created.millisecondsSinceEpoch,
          id: message.id,
          text: message.content,
        );
      } else if (authorId == receiverId) {
        return types.TextMessage(
          author: _user,
          createdAt: message.created.millisecondsSinceEpoch,
          id: message.id,
          text: message.content,
        );
      } else {
        throw Exception('Invalid authorId: $authorId');
      }
    }).toList();
    //遍历querySnapshot.docs，将其add到_messages中
    querySnapshot.docs.forEach((element) {
      _messages.add(element);
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
                              ProfileScreen(uid: widget.opuser.toString()),
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

  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
    //发送消息
    final textMsg = msg.Message(
      id: textMessage.id ,
      senderId: int.parse(widget.user),
      receiverId: int.parse(widget.opuser), // 这里需要根据具体场景设置receiverId
      content: textMessage.text,
      created: DateTime.fromMillisecondsSinceEpoch(textMessage.createdAt  ?? 0),
    );

    db.DataBaseManager dbm = db.DataBaseManager();
    dbm.createMessage(textMsg.senderId, textMsg.receiverId, textMessage.text);
    // dbm.createNotice(1,textMessage.text,textMsg.senderId,textMsg.receiverId);
    // dbm.getChatHistory(textMsg.senderId, textMsg.receiverId);
    // refresh(querySnapshot,textMsg.senderId,textMsg.receiverId);
  }
}