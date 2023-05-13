import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/utils.dart';
import 'package:provider/provider.dart';

import '../Auth/customAuth.dart';
import '../resources/database_methods.dart' as db;

class FollowedScreen extends StatefulWidget {
  final List<dynamic> followedList;
  //final String uid;
  const FollowedScreen({Key? key,required this.followedList}) : super(key: key);

  @override
  _FollowedScreenState createState() => _FollowedScreenState();
}

class _FollowedScreenState extends State<FollowedScreen> {

  bool isLoading = false;
  List<Row> followeds = [];
  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      followeds = await buildFollowed(widget.followedList);

      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    ):
      Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){Navigator.of(context).pop();},
        ),
        title: const Text(
          '关注列表',
        ),
        centerTitle: false,
      ),
      body: Column(
        // children: widget.followedList.map((key, value) {
        //   for (var item in post['zones']) {
        //     print("title "+ item['title']);
        //     Container(
        //       child: Text(item["title"]),
        //     ); //Container
        //   }
        //   throw ArgumentError();
        //
        // }).toList(),
        children: followeds,
      ),
    );
  }
}

Future<List<Row>> buildFollowed(List<dynamic> followedList) async {
  List<Row> rows = [];
  var jwt = CustomAuth.currentUser.jwt;
  for(var item in followedList){
    var url = Uri.parse("http://127.0.0.1:5000/api/user/user/"+item['followedUserId']);
    Map<String,dynamic> userinfo = await db.DataBaseManager().getSomeMap(url);
    rows.add(Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(
            //userData['photoUrl'],  //TODO
              "https://p0.itc.cn/q_70/images03/20230213/ca107acd0ee943a0ac9e8264a23b6ca4.jpeg"
          ),
          radius: 40,
        ),
        Text(userinfo['username']),
      ],
    ));
  }
  return rows;
}
