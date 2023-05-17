
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/profile_screen.dart';
import '../utils/colors.dart';
// import '../utils/global_variable.dart';
import '../utils/global_variable.dart' as gv;
import '../resources/database_methods.dart' as db;
import '../utils/global_variable.dart';
import '../utils/utils.dart';
class ContactUserCard extends StatefulWidget{
  final snap;
  const ContactUserCard({
    Key? key,
    required this.snap,
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
      print(snap['userId']);
      db.DataBaseManager dbm = db.DataBaseManager();
      String userId = snap['userId'].toString();
      var url = Uri.parse("${gv.ip}/api/user/user/$userId");
      userinfo = await dbm.getSomeMap(url);
      print("userinfo");
      // print(userinfo);
      _file = await dbm.getPhoto(userId);
      print("file");
      // print(_file);
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
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
        color: mobileBackgroundColor,
        borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 16,
          ).copyWith(right: 0),
          child: Row(
            children: <Widget>[
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
                    backgroundImage: MemoryImage(_file!),
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
                      Text(
                        widget.snap['created'].toString(),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // 处理删除按钮点击事件
                  // 这里可以调用您的删除通知的方法
                },
              ),
            ],
          ),
        )
        ],
      ),
    );
  }
}