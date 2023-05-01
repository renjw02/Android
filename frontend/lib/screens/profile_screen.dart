// import 'package:flutter/material.dart';
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({Key? key, required String uid}) : super(key: key);
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }
// class _ProfileScreenState extends State<ProfileScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text('ProfileScreen'),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/resources/auth_methods.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/utils.dart';
import 'package:frontend/widgets/follow_button.dart';
import 'package:http/http.dart' as http;

import '../Auth/customAuth.dart';

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
  int followed = 0;
  bool isFollowed = false;
  bool isLoading = false;
  String currentUserUid = "";

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

      Map<String, dynamic> userinfo={};//获取用户信息
      var _client = http.Client();
      var url = Uri.parse("http://127.0.0.1:5000/api/user/user/"+widget.uid);
      //var url = Uri.parse("http://127.0.0.1:5000/api/user/user");
      print(widget.uid);
      print(CustomAuth.currentUser.jwt);
      Map<String, String> requestHeaders = {
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
      };
      await _client.get(
          url,
          headers: requestHeaders,
      ).then((http.Response response) {
        //处理响应信息
        if (response.statusCode == 200) {
          print("asd1");
          print(response.body);
          //userinfo = response.body;
          userinfo = jsonDecode(response.body);
          print(userinfo);
        } else {
          print('error');
          print(response.body);
        }
      }).catchError((e){
        print(e);
      });
      print("asd2");
      Map<String, dynamic> userFollowers={}; //获取关注我的人
      url = Uri.parse("http://127.0.0.1:5000/api/user/getfollowerlist");
      await _client.get(
        url,
        headers: requestHeaders,
      ).then((http.Response response) {
        //处理响应信息
        if (response.statusCode == 200) {
          print(response.body);
          // userFollowers = response.body;
          userFollowers = jsonDecode(response.body);
        } else {
          print('error');
        }
      });
      print("asd3");
      Map<String, dynamic> userFollowed={}; //获取我关注的人
      url = Uri.parse("http://127.0.0.1:5000/api/user/getfollowedlist/1");
      await _client.get(
        url,
        headers: requestHeaders,
      ).then((http.Response response) {
        //处理响应信息
        if (response.statusCode == 200) {
          print(response.body);
          // userFollowed = response.body;
          userFollowed = jsonDecode(response.body);
        } else {
          print('error');
        }
      });
      print("asd4");

      // get post lENGTH
      // var postSnap = await FirebaseFirestore.instance
      //     .collection('posts')
      //     .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      //     .get();

      //postLen = postSnap.docs.length;
      print(userinfo);
      userData = userinfo;
      followers = 0;//userFollowers['totalNum'];
      //following = userSnap.data()!['following'].length;
      followed = 0;//userFollowed['totalnum'];
      // isFollowed = userSnap
      //     .data()!['followers']
      //     .contains(FirebaseAuth.instance.currentUser!.uid);
      isFollowed = false;
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
    )
        : Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          userData['nickname'], //TODO
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
                      backgroundImage: NetworkImage(
                        //userData['photoUrl'],  //TODO
                        "https://p0.itc.cn/q_70/images03/20230213/ca107acd0ee943a0ac9e8264a23b6ca4.jpeg"
                      ),
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
                              buildStatColumn(111, "posts"),
                              buildStatColumn(followers, "followers"),
                              buildStatColumn(followed, "followed"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              currentUserUid ==
                                  widget.uid
                                  ? FollowButton(
                                text: 'Sign Out',
                                backgroundColor:
                                mobileBackgroundColor,
                                textColor: primaryColor,
                                borderColor: Colors.grey,
                                function: () async {
                                  // await AuthMethods().signOut();  //TODO
                                  Navigator.of(context)
                                      .pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const LoginScreen(),
                                    ),
                                  );
                                },
                              )
                                  : isFollowed
                                  ? FollowButton(
                                text: 'Unfollow',
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
                                text: 'Follow',
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
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Text(
                    // userData['username'],  //TODO
                    userData['nickname'],  //TODO
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 1,
                  ),
                  child: Text(
                    userData['nickname'], //TODO
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          FutureBuilder(
            // future: FirebaseFirestore.instance
            //     .collection('posts')
            //     .where('uid', isEqualTo: widget.uid)
            //     .get(),
            // 获取当前信息页面用户发布的动态
            future: null,  //TODO
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                itemCount: (snapshot.data! as dynamic).docs.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 1.5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  // DocumentSnapshot snap =
                  // (snapshot.data! as dynamic).docs[index];
                  // 获取动态  TODO

                  return Container(
                    child: Image(
                      // image: NetworkImage(snap['postUrl']),  //TODO
                      image: NetworkImage("https://p0.itc.cn/q_70/images03/20230213/ca107acd0ee943a0ac9e8264a23b6ca4.jpeg"),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            },
          )
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
