// TODO Implement this library.
import 'package:flutter/material.dart';
import '../Auth/customAuth.dart';
import '../models/post.dart';
import '../models/comment.dart' as commentModel;
import '../utils/text_helper.dart';
import 'package:cached_network_image/cached_network_image.dart' as cni;
import '../utils/global_variable.dart' as gv;
import 'Avatar.dart';

class Comment extends StatelessWidget {
  const Comment( {super.key, required this.comment});
  final commentModel.Comment comment;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width ,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey, // 设置边框颜色
                width: 1, // 设置边框宽度
              ),
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20), // 设置圆角半径
            ),
            padding: const EdgeInsets.only(left: 20,right: 0),
            margin: const EdgeInsets.only(left: 18,right: 18,top: 8),
            child: Flex(
                direction: Axis.horizontal,
                children: [
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(30.0),
                  //   child: CircleAvatar(
                  //     child: cni.CachedNetworkImage(
                  //       imageUrl:
                  //       "${gv.ip}/api/user/downloadavatar?name=${comment.userId}.jpg",
                  //       httpHeaders: {
                  //         'Authorization': CustomAuth.currentUser.jwt,
                  //       },
                  //       placeholder: (context, url) => const SizedBox(
                  //           width: 10, height: 10, child: CircularProgressIndicator()),
                  //       errorWidget: (context, url, error) => const Icon(Icons.error),
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  // ),
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
                                            comment.created.toString().substring(5, 10),
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