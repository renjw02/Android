// TODO Implement this library.
import 'package:flutter/material.dart';
import '../Auth/customAuth.dart';
import '../models/post.dart';
import '../models/comment.dart' as commentModel;
import '../utils/text_helper.dart';
import 'package:cached_network_image/cached_network_image.dart' as cni;
import '../utils/global_variable.dart' as gv;

class Comment extends StatelessWidget {
  const Comment( {super.key, required this.comment});
  final commentModel.Comment comment;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width ,
      color: Colors.blue.withOpacity(0.05),
      child: Column(

        children: [
          Divider(
            color: Colors.grey,
            thickness: 1,),
          Container(
            padding: const EdgeInsets.only(left: 20,right: 0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: CircleAvatar(
                    child: cni.CachedNetworkImage(
                      imageUrl:
                      "${gv.ip}/api/user/downloadavatar?name=${comment.userId}.jpg",
                      httpHeaders: {
                        'Authorization': CustomAuth.currentUser.jwt,
                      },
                      placeholder: (context, url) => const SizedBox(
                          width: 10, height: 10, child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                    children:[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        margin: const EdgeInsets.only(left: 18,right: 0,top: 8),
                        padding: const EdgeInsets.only(left: 0,right: 0,top: 18),
                        child: ListTile(
                            title: comment.content == null ? Container() : Text(textConverter(comment!.content)),
                            subtitle: comment.userId == null
                                ? const Text("the comments already deleted")
                                : Padding(
                                padding: const EdgeInsets.only(top: 8,right: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(comment.userId.toString()),
                                    Text(comment.created.toString().substring(5,10)),
                                  ],
                                )
                            )),
                      ),
                      const Divider(),
                    ],
                    // comment.comments.forEach((kidcomment) => children.add(Comment( itemMap , comment:commentModel.Comment.fromDbMap(kidcomment))));
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}