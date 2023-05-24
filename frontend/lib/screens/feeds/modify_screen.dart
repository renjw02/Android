import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../Auth/customAuth.dart';
import '../../models/user.dart';
import '../../resources/database_methods.dart' as db;
import '../profile_screen.dart';

class ModifyScreen extends StatefulWidget {
  const ModifyScreen({Key? key}) : super(key: key);

  @override
  _ModifyScreenState createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController usernamec = new TextEditingController(text: CustomAuth.currentUser.username);
  final TextEditingController profilec = new TextEditingController(text: CustomAuth.currentUser.profile);
  final TextEditingController passwordc = new TextEditingController(text: CustomAuth.currentUser.password);
  final Uint8List _photo = CustomAuth.currentUser.photo;

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('更换头像'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('拍照'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('上传本地图片'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("取消"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future<String> modifyInfo(String u,String p,String w)async {
    var cu = CustomAuth.currentUser;
    String res = await db.DataBaseManager().changeInfo(u,cu.nickname,p,w);
    if(res == "Fail"){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("修改失败"),
        ),
      );
      return res;
    }
    if(_file != null){
      print("upload photo");
      String res = await db.DataBaseManager().uploadPhoto(_file!);
      if(res == "Fail"){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("修改失败"),
          ),
        );
        return res;
      }
      CustomAuth.currentUser = new User(
          username: u,
          uid: CustomAuth.currentUser.uid,
          jwt: CustomAuth.currentUser.jwt,
          photoUrl: CustomAuth.currentUser.photoUrl,
          photo: _file!,
          email: CustomAuth.currentUser.email,
          password: w,
          nickname: CustomAuth.currentUser.nickname,
          profile: p,
          followers: CustomAuth.currentUser.followers,
          following: CustomAuth.currentUser.following,
          blockList: CustomAuth.currentUser.blockList,
      );
    }
    return res;
  }

  @override
  void dispose() {
    super.dispose();
    usernamec.dispose();
    profilec.dispose();
    passwordc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.of(context).pop();
            setState(() {
            });
          },
          // onPressed: (){Navigator.of(context).pushReplacement(MaterialPageRoute(
          //               builder: (context) =>
          //               ProfileScreen(uid: CustomAuth.currentUser.uid),
          //               ));},
        ),
        title: const Text(
          '修改信息',
        ),
        centerTitle: false,
        actions: <Widget>[
          TextButton(
            onPressed: ()async {
              String res = await modifyInfo(
                usernamec.text,
                profilec.text,
                passwordc.text,
              );
              print(res);
              if(res == "Success"){
                Map<String,dynamic> result = {};
                result["username"] = usernamec.text;
                result["profile"] = profilec.text;
                if(_file != null){
                  result["photo"] = _file;
                }
                else{
                  result["photo"] = _photo;
                }
                Navigator.of(context).pop(result);
              }

              // Navigator.of(context).pushReplacement(MaterialPageRoute(
              //   builder: (context) =>
              //   ProfileScreen(uid: CustomAuth.currentUser.uid),
              // ),);
            },
            child: const Text(
              "完成",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: usernamec,
            decoration: const InputDecoration(
              labelText: "用户名",
              prefixIcon: Icon(Icons.person),
            )
          ),
          TextField(
              controller: profilec,
              decoration: const InputDecoration(
                labelText: "简介",
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: null,
              minLines: 1,
          ),
          TextField(
              controller: passwordc,
              decoration: const InputDecoration(
                labelText: "密码",
                prefixIcon: Icon(Icons.lock),
              )
          ),
          _file == null
          ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(top: 0.0)),
              const Divider(),
              SizedBox(
                height: 45.0,
                width: 45.0,
                child: AspectRatio(
                  aspectRatio: 487 / 451,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          alignment: FractionalOffset.topCenter,
                          image: MemoryImage(CustomAuth.currentUser.photo),
                        )),
                  ),
                ),
              ),
              Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.upload,
                  ),
                  onPressed: () => _selectImage(context),
                ),
              ),
              const Divider(),
            ],): Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 45.0,
                      width: 45.0,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                alignment: FractionalOffset.topCenter,
                                image: MemoryImage(_photo),
                                // image : NetworkImage(
                                //   // userProvider.getUser.photoUrl,
                                //     "https://p0.itc.cn/q_70/images03/20230213/ca107acd0ee943a0ac9e8264a23b6ca4.jpeg"
                                // ),
                              )),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 45.0,
                      width: 45.0,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                alignment: FractionalOffset.topCenter,
                                image: MemoryImage(_file!),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ]
            )
        ],
      ),
    );
    // return _file == null
    //     ? Center(
    //   child: IconButton(
    //     icon: const Icon(
    //       Icons.upload,
    //     ),
    //     onPressed: () => _selectImage(context),
    //   ),
    // )
    //     : Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: mobileBackgroundColor,
    //     leading: IconButton(
    //       icon: const Icon(Icons.arrow_back),
    //       onPressed: clearImage,
    //     ),
    //     title: const Text(
    //       'Post to',
    //     ),
    //     centerTitle: false,
    //     actions: <Widget>[
    //       TextButton(
    //         onPressed: () => postImage(
    //           userProvider.getUser.uid,
    //           userProvider.getUser.username,
    //           userProvider.getUser.photoUrl,
    //         ),
    //         child: const Text(
    //           "Post",
    //           style: TextStyle(
    //               color: Colors.blueAccent,
    //               fontWeight: FontWeight.bold,
    //               fontSize: 16.0),
    //         ),
    //       )
    //     ],
    //   ),
    //   // POST FORM
    //   body: Column(
    //     children: <Widget>[
    //       isLoading
    //           ? const LinearProgressIndicator()
    //           : const Padding(padding: EdgeInsets.only(top: 0.0)),
    //       const Divider(),
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: <Widget>[
    //           CircleAvatar(
    //             backgroundImage: NetworkImage(
    //               userProvider.getUser.photoUrl,
    //             ),
    //           ),
    //           SizedBox(
    //             width: MediaQuery.of(context).size.width * 0.3,
    //             child: TextField(
    //               controller: _descriptionController,
    //               decoration: const InputDecoration(
    //                   hintText: "Write a caption...",
    //                   border: InputBorder.none),
    //               maxLines: 8,
    //             ),
    //           ),
    //           SizedBox(
    //             height: 45.0,
    //             width: 45.0,
    //             child: AspectRatio(
    //               aspectRatio: 487 / 451,
    //               child: Container(
    //                 decoration: BoxDecoration(
    //                     image: DecorationImage(
    //                       fit: BoxFit.fill,
    //                       alignment: FractionalOffset.topCenter,
    //                       image: MemoryImage(_file!),
    //                     )),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //       const Divider(),
    //     ],
    //   ),
    // );
  }
}
