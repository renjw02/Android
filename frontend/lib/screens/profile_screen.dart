import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/resources/auth_methods.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/utils.dart';
import 'package:frontend/widgets/follow_button.dart';
import 'package:http/http.dart' as http;

import '../Auth/customAuth.dart';
import '../models/user.dart';
import '../resources/database_methods.dart' as db;
import 'followed_screen.dart';
import 'modify_screen.dart';
import '../utils/global_variable.dart' as gv;

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  Map<String, dynamic> followed = {};
  bool isFollowed = false;
  bool isLoading = false;
  String currentUserUid = "";
  Uint8List? _photo;
  dynamic photo;

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
      // var userSnap = await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(widget.uid)
      //     .get();
      currentUserUid = CustomAuth.currentUser.uid;
      db.DataBaseManager dbm = db.DataBaseManager();
      Map<String, dynamic> userinfo={};//获取用户信息
      var url = Uri.parse(gv.ip+"/api/user/user/"+widget.uid);
      //var url = Uri.parse("http://127.0.0.1:5000/api/user/user");
      userinfo = await dbm.getSomeMap(url);
      Map<String, dynamic> userFollowers={}; //获取关注我的人
      url = Uri.parse(gv.ip+"/api/user/getfollowerlist/"+widget.uid);
      userFollowers = await dbm.getSomeMap(url);
      print(userFollowers);
      // print("followtest");
      // await followtest();
      Map<String, dynamic> userFollowed={}; //获取我关注的人
      url = Uri.parse(gv.ip+"/api/user/getfollowedlist/"+widget.uid);
      userFollowed = await dbm.getSomeMap(url);
      print(userFollowed.runtimeType);
      print(userFollowed['followedList'].runtimeType);
      print(userFollowed['followedList'].length);

      print(userinfo);
      print(userinfo['id']);
      print(userinfo['id'].runtimeType);
      print(currentUserUid);
      _photo = await dbm.getPhoto(userinfo['id'].toString());
      photo = MemoryImage(_photo!);

      userData = Map.from(userinfo);
      userData['profile'] = userinfo['profile']==null?"profile":userinfo['profile'];
      followers = userFollowers['totalNum'];
      followed = Map.from(userFollowed);
      print(followed);
      print(followed['followedList'].runtimeType);
      print(followed['followedList'].length);
      print(userinfo['username']);
      if(userData['id'].toString() == currentUserUid){
        CustomAuth.currentUser = new User(
          username: CustomAuth.currentUser.username,
          uid: CustomAuth.currentUser.uid,
          jwt: CustomAuth.currentUser.jwt,
          photoUrl: CustomAuth.currentUser.photoUrl,
          email: CustomAuth.currentUser.email,
          password: CustomAuth.currentUser.password,
          nickname: CustomAuth.currentUser.nickname,
          profile:CustomAuth.currentUser.profile,
          photo: CustomAuth.currentUser.photo,
          followers: userFollowers['followerList'],
          following: userFollowed['followedList'],
        );
      }
      isFollowed = userFollowers['followerList'].indexOf(currentUserUid) != -1;
      print(isFollowed);
      //isFollowed = true;
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
  Future<void> followtest() async {
    await db.DataBaseManager().followUser("2");
    print("followtest");
  }
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          userData['username'], //TODO
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: photo,
                      radius: 40,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              //buildStatColumn(postLen, "posts"),  //TODO
                              buildStatColumn(111, "发布数"),
                              userData['id'].toString() == currentUserUid?
                              GestureDetector(
                                onTap: ()async {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      FollowedScreen(followedList : CustomAuth.currentUser.following,),
                                      //const LoginScreen(),
                                    ),
                                  );
                                },
                                child:Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    CustomAuth.currentUser.following.length.toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "关注数",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              ):GestureDetector(
                                  onTap: ()async {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FollowedScreen(followedList : followed['followedList'],),
                                        //const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child:Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        followed['followedList'].length.toString(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          "关注数",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                              buildStatColumn(CustomAuth.currentUser.followers.length, "粉丝数"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              currentUserUid ==
                                  widget.uid
                                  ? Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children:[FollowButton(
                                text: '退出登录',
                                backgroundColor:
                                mobileBackgroundColor,
                                textColor: primaryColor,
                                borderColor: Colors.grey,
                                function: () async {
                                  var res = await CustomAuth().signOut();  //TODO
                                  if(res == "Success"){
                                    Navigator.of(context)
                                        .pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const LoginScreen(),
                                      ),
                                    );
                                  }
                                  else{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("登出失败"),
                                      ),
                                    );
                                  }
                                },
                              ),Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(
                                  top: 1,
                                ),
                                child:
                                currentUserUid == widget.uid?
                                FollowButton(
                                  text: '修改信息',
                                  backgroundColor:mobileBackgroundColor,
                                  textColor: primaryColor,
                                  borderColor: Colors.grey,
                                  function: () async {
                                    //TODO  修改信息
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const ModifyScreen(),
                                      ),
                                    ).then((val){
                                      setState(() {
                                        print(val);
                                        print(val.runtimeType);
                                        userData['username'] = val['username'];
                                        userData['profile'] = val['profile'];
                                        photo = MemoryImage(val['photo']);
                                      });
                                    });

                                  },
                                ):Text("你谁啊")
                              ) ,]
                              ): isFollowed
                                  ? FollowButton(
                                text: '取消关注',
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                borderColor: Colors.grey,
                                function: () async {
                                  // await FireStoreMethods()
                                  //     .followUser(
                                  //   FirebaseAuth.instance
                                  //       .currentUser!.uid,
                                  //   userData['uid'],
                                  // );
                                  //  取消对当前信息页面用户的关注
                                  setState(() {
                                    isFollowed = false;
                                    followers--;
                                  });
                                },
                              )
                                  : FollowButton(
                                text: '关注',
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                                borderColor: Colors.blue,
                                function: () async {
                                  // await FireStoreMethods()
                                  //     .followUser(
                                  //   FirebaseAuth.instance
                                  //       .currentUser!.uid,
                                  //   userData['uid'],
                                  // );
                                  //  关注当前信息页面用户

                                  setState(() {
                                    isFollowed = true;
                                    followers++;
                                  });
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Container(
                //   alignment: Alignment.centerLeft,
                //   padding: const EdgeInsets.only(
                //     top: 15,
                //   ),
                //   child: Text(
                //     // userData['username'],  //TODO
                //     userData['nickname'],  //TODO
                //     style: TextStyle(
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 1,
                  ),
                  child: Text(
                    userData['profile'], //TODO
                  ),
                ),

              ]),
    ),
          const Divider(),
          // FutureBuilder(
          //   // future: FirebaseFirestore.instance
          //   //     .collection('posts')
          //   //     .where('uid', isEqualTo: widget.uid)
          //   //     .get(),
          //   // 获取当前信息页面用户发布的动态
          //   future: null,  //TODO
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     }
          //
          //     return GridView.builder(
          //       shrinkWrap: true,
          //       itemCount: (snapshot.data! as dynamic).docs.length,
          //       gridDelegate:
          //       const SliverGridDelegateWithFixedCrossAxisCount(
          //         crossAxisCount: 3,
          //         crossAxisSpacing: 5,
          //         mainAxisSpacing: 1.5,
          //         childAspectRatio: 1,
          //       ),
          //       itemBuilder: (context, index) {
          //         // DocumentSnapshot snap =
          //         // (snapshot.data! as dynamic).docs[index];
          //         // 获取动态  TODO
          //
          //         return Container(
          //           child: Image(
          //             // image: NetworkImage(snap['postUrl']),  //TODO
          //             image: NetworkImage("https://p0.itc.cn/q_70/images03/20230213/ca107acd0ee943a0ac9e8264a23b6ca4.jpeg"),
          //             fit: BoxFit.cover,
          //           ),
          //         );
          //       },
          //     );
          //   },
          // )
        ],
      ),
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
