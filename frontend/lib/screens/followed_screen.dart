import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/utils.dart';
import 'package:provider/provider.dart';

import '../Auth/customAuth.dart';
import '../resources/database_methods.dart' as db;
import '../utils/global_variable.dart' as gv;

class FollowedScreen extends StatefulWidget {
  final List<dynamic>? followedList;
  //final String uid;
  const FollowedScreen({Key? key,required this.followedList}) : super(key: key);

  @override
  _FollowedScreenState createState() => _FollowedScreenState();
}

class _FollowedScreenState extends State<FollowedScreen> {

  bool isLoading = false;
  List<Row> followeds = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

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
      body: followeds.length==0?
      Text("没有关注的人，o.0"):
      Column(
        children: followeds,
      ),
    );
  }

  Future<List<Row>> buildFollowed(List<dynamic>? followedList) async {
    List<Row> rows = [];
    var jwt = CustomAuth.currentUser.jwt;
    if(followedList==null)return rows;
    for(var item in followedList){
      print("start");
      print(item);
      var url = Uri.parse(gv.ip+"/api/user/user/"+item['followedUserId'].toString());
      print(url);
      Map<String,dynamic> userinfo = await db.DataBaseManager().getSomeMap(url);
      print(userinfo);
      Uint8List _photo = await db.DataBaseManager().getPhoto(item['followedUserId'].toString());
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage:
            MemoryImage(_photo),
            radius: 40,
          ),
          SizedBox(
            width: 20.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children:[
              TextButton(
                onPressed:(){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                      ProfileScreen(uid: item['followedUserId'].toString()),
                    ),
                  );
                },
                child:Text(userinfo['username'],style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Text(userinfo['profile']==null?"profile":userinfo['profile']),
            ]
          )
        ],
      ));
    }
    return rows;
  }
}

