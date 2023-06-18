// TODO Implement this library.
import 'package:flutter/material.dart';

import '../models/comment.dart' as commentModel;
import '../utils/colors.dart';
import '../utils/text_helper.dart';
import 'package:cached_network_image/cached_network_image.dart' as cni;
import '../utils/global_variable.dart' as gv;
import 'avatar.dart';

class Comment extends StatelessWidget {
  const Comment( {super.key, required this.comment});
  final commentModel.Comment comment;
  @override
  Widget build(BuildContext context) {
    return Card(
      // width: MediaQuery.of(context).size.width ,
      margin: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 7.5,
      ),
      elevation: 5.0,
      color:mobileBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              // border: Border.all(
              //   color: Colors.grey, // 设置边框颜色
              //   width: 1, // 设置边框宽度
              // ),
              // color: Colors.black45,
              borderRadius: BorderRadius.circular(20), // 设置圆角半径
            ),
            padding: const EdgeInsets.only(left: 20,right: 0),
            margin: const EdgeInsets.only(left: 9,right: 9,top: 4,bottom: 4),
            child: Flex(
                direction: Axis.horizontal,
                children: [
                  UserAvatar(userId: comment.userId.toString(),width: 50,height: 50),
                  Expanded(
                    child:Container(
                            // width: MediaQuery.of(context).size.width * 0.5,
                            margin: const EdgeInsets.only(left: 18,right: 0,top: 8),
                            padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                            child: ListTile(
                                title: comment.content == null ? Container() : Text(textConverter(comment.content)),
                                subtitle: comment.nickname == null
                                    ? const Text("the comments already deleted")
                                    : Padding(
                                      padding: const EdgeInsets.only(top: 8, right: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            comment.nickname,
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                          Text(
                                            comment.created.toString().substring(5, 16),
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    )

                            ),
                          ),
                  ),
                ],
              ),

          ),
        ],
      ),
    );
  }
}