import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart' as model;
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/resources/textpost_methods.dart';
import 'package:frontend/screens/comments_screen.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/global_variable.dart';
import 'package:frontend/utils/utils.dart';
import 'package:frontend/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/global_variable.dart' as gv;
import '../resources/database_methods.dart' as db;

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  //int commentLen = 0;
  bool isLikeAnimating = false;
  Map<String,dynamic> userinfo = {};
  Uint8List? _file;
  Map<String,Color> colors = {"red":Colors.red,"white":Colors.white,"yellow":Colors.yellow};
  Map<String,FontWeight> weights = {"较细":FontWeight.w300,"适中":FontWeight.w500,"较粗":FontWeight.w700};
  bool isLoading = false;

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
      db.DataBaseManager dbm = db.DataBaseManager();
      var url = Uri.parse(gv.ip+"/api/user/user/"+snap['uid']);
      userinfo = await dbm.getSomeMap(url);
      _file = await dbm.getPhoto(snap['uid']);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  deletePost(String postId) async {  //TODO
    try {
      await TextPostMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    ):Container(
      // boundary needed for web
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
          //分割线
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),
          // HEADER SECTION OF THE POST
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundImage: MemoryImage(_file!),
                  // backgroundImage: NetworkImage(
                  //   widget.snap['profImage'].toString(),
                  // ),
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
                      ],
                    ),
                  ),
                ),
                widget.snap['uid'].toString() == user.uid
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ListView(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shrinkWrap: true,
                                    children: [
                                      'Delete',
                                    ]
                                        .map(
                                          (e) => InkWell(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Text(e),
                                              ),
                                              onTap: () {
                                                deletePost(
                                                  widget.snap['id']
                                                      .toString(),
                                                );
                                                // remove the dialog box
                                                Navigator.of(context).pop();
                                              }),
                                        )
                                        .toList()),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_vert),
                      )
                    : Container(),
              ],
            ),
          ),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () {
              TextPostMethods().likePost(
                widget.snap['id'].toString(),
                user.uid,
                widget.snap['support_num'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(10.0), // 设置边距
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
                      child: Image.network(
                        //widget.snap['postUrl'].toString(),
                        'https://picsum.photos/200/303',
                        fit: BoxFit.cover),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                LikeAnimation(
                  isAnimating: widget.snap['supportList'].contains(user.uid),
                  smallLike: true,
                  child: IconButton(
                    icon: widget.snap['supportList'].contains(user.uid)//判断是否点赞
                    ? const Icon(
                      Icons.favorite,
                      color: Colors.red,)
                    : const Icon(Icons.favorite_border,),
                    onPressed: () => TextPostMethods().likePost(
                      widget.snap['postId'].toString(),
                      user.uid,
                      widget.snap['supportList'],
                    ),
                  ),
                ),
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                  '${widget.snap['support_num']} ',
                  style: Theme.of(context).textTheme.bodyMedium,)
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined,),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: widget.snap['postId'].toString(),
                      ),
                    ),
                  ),
                ),
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                  '${widget.snap['comment_num']}',
                  style: Theme.of(context).textTheme.bodyText2,
                )),
                  IconButton( //转发按钮
                    icon: const Icon(Icons.send,),
                    onPressed: () {}
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child:IconButton(
                        icon: widget.snap['starList'].contains(user.uid)
                            ? const Icon(
                          Icons.star,
                          color: Colors.red,
                        ) : const Icon(Icons.star_border),
                        onPressed:(){},
                      ),
                    )
                  )
                ],
              ),
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${widget.snap['support_num']} 点赞',
                      style: Theme.of(context).textTheme.bodyText2,
                    )),
                Column(
                  children:[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child:RichText(
                        text:TextSpan(
                          text: "${userinfo['username']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: ' ${widget.snap['content']}',
                          style: TextStyle(fontSize: widget.snap['font_size'],color: colors[widget.snap['font_color']],
                              fontWeight: weights[widget.snap['font_weight']]),
                        ),
                      ),
                    )
                  ]
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '查看所有 ${widget.snap['comment_num']} 条评论',
                      style: const TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: widget.snap['id'].toString(),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child:
                  Text(
                    // DateFormat.yMMMd()
                    //     .format(widget.snap['datePublished'].toDate()),
                    widget.snap['created'].toString(),
                    style: const TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
