import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Auth/customAuth.dart';
import '../screens/profile_screen.dart';
import '../utils/global_variable.dart';
import '../resources/database_methods.dart' as db;

class UserAvatar extends StatefulWidget {
  final String userId;
  final double? width;
  final double? height;
  const UserAvatar({
    Key? key,
    required this.userId,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  Uint8List? _bytesImage;
  dynamic avatar;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
    // _getAvatar();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      _bytesImage = await db.DataBaseManager().getPhoto(widget.userId.toString());
      avatar = MemoryImage(_bytesImage!);
    }catch(e){
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(uid: widget.userId),
                  //const LoginScreen(),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: avatar,
              radius: 20,
              //     width: widget.width == null ? 32 : widget.width,
              //     height: widget.height == null ? 32 : widget.height,
            ),
            // child: ClipOval(
            //   child: CachedNetworkImage(
            //     imageUrl: "$ip/api/user/downloadavatar?name=${widget.userId}.jpg",
            //     httpHeaders: {
            //       'Authorization': CustomAuth.currentUser.jwt,
            //     },
            //     placeholder: (context, url) => const CircularProgressIndicator(),
            //     errorWidget: (context, url, error) => const Icon(Icons.error),
            //     width: widget.width == null ? 32 : widget.width,
            //     height: widget.height == null ? 32 : widget.height,
            //   ),
            // ),
        ),

      ],
    );
  }
}
