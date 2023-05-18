
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/notice_screen.dart';

import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/colors.dart';
// import '../utils/global_variable.dart';
import '../utils/global_variable.dart' as gv;
import '../resources/database_methods.dart' as db;
import '../utils/global_variable.dart';
import '../utils/utils.dart';
class ContactUserCard extends StatefulWidget{
  final snap;
  final VoidCallback? onRemoved;
  const ContactUserCard({
    Key? key,
    required this.snap,
    this.onRemoved,
  }) : super(key: key);

  @override
  State<ContactUserCard> createState() => _ContactUserCardState();
}
class _ContactUserCardState extends State<ContactUserCard> {
  bool isLoading = false;
  late final Uint8List _file;
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
      print(snap['creatorId']);
      db.DataBaseManager dbm = db.DataBaseManager();
      String noticeCreator = snap['noticeCreator'].toString();
      var url = Uri.parse("${gv.ip}/api/user/user/$noticeCreator");
      //获取帖子内容

      userinfo = await dbm.getSomeMap(url);
      print("userinfo");
      // print(userinfo);
      _file = await dbm.getPhoto(noticeCreator);
      print("file");
      // print(_file);
      //获取帖子内容
      String content = await dbm.noticeContentQuery(snap['noticeId']);
      snap["content"] = content;
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
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    ):Container(

      margin: const EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 5,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : Colors.grey,
        ),
        color: chatPrimaryColor,
        borderRadius: BorderRadius.circular(20.0), // 设置圆角半径
      ),
    child: GestureDetector(
      onTap: () {
        widget.snap["hasChecked"] = 1;
        setState(() {}); // 触发rebuild
        if (widget.snap["noticeType"] == 1) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                snap: widget.snap,
                file: _file,
              ),
            ),
          );
        }else{
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NoticeScreen(
                snap: widget.snap,
                file: _file,
              ),
            ),
          );
        }
      },
        child: Column(
          children: [
            // const Divider(
            //   height: 1,
            //   thickness: 1,
            //   color: Colors.grey,
            // ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(uid: widget.snap['userId'].toString()),
                          ),
                        );
                        //获取聊天内容
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: MemoryImage(_file!),
                      ),
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
                            Text(
                              widget.snap['created'].millisecondsSinceEpoch.toString(),
                            ),
                            Text(
                              widget.snap['content'].toString(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.snap["noticeType"] == 1) // 判断通知类型是否为私信
                      const Text(
                        "私信",
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (widget.snap["noticeType"] == 0) // 判断通知类型是否为系统通知
                      const Text(
                        "系统通知",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    InkWell(
                      onTap: () async {
                        // 删除通知
                        //如果已读，删除通知
                        if (widget.snap["hasChecked"] == 1){
                          widget.onRemoved?.call();
                        }else{
                          //弹窗通知用户消息未读
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("提示"),
                                content: const Text("消息未读，无法删除"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("确定"),
                                  ),
                                ],
                              );
                            },
                          );
                        }

                        // 处理按钮点击事件
                      },
                      child: Ink(
                        decoration: ShapeDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          shape: const CircleBorder(),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.snap["hasChecked"] == 0) // 判断通知是否已读
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          )
          ],
        ),
      ),
    );
  }
}