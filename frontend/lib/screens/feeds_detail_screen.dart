import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart' as cni;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:frontend/utils/colors.dart';
import '../Auth/customAuth.dart';
import '../models/post.dart';
import '../resources/web_service/comment_api_service.dart';
import '../utils/global_variable.dart' as gv;
import '../widgets/comment.dart';
import '../resources/database_methods.dart' as db;
import '../models/comment.dart' as commentModel;
class FeedsDetailScreen extends StatefulWidget {
  final int id;
  final Post post;
  final bloc;
  const FeedsDetailScreen({super.key, required this.id, required this.post, this.bloc});

  @override
  State<FeedsDetailScreen> createState() => _FeedsDetailScreenState();
}

class _FeedsDetailScreenState extends State<FeedsDetailScreen>
    with SingleTickerProviderStateMixin {
  bool isLike = false;
  bool isCommentPanelOpen = false;
  void _onScroll() {
    setState(() {
      isCommentPanelOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.5;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.post.title),
        ),
        body: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: isCommentPanelOpen
              ? CommentPanel(onClose: _onScroll, postId: widget.post.id,bloc : widget.bloc)
              : _buildBody( context),
        ),
        bottomNavigationBar: BottomAppBar(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              SizedBox(
                child: IconButton(
                  iconSize: 40,
                  // padding: EdgeInsets.all(10), // 内边距10
                  constraints: const BoxConstraints(
                      minWidth: 120, maxWidth: 150), // 宽度在50-70之间
                  icon: Stack(children: [
                    Container(
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                          color: isLike ? Colors.lightBlue : Colors.grey,
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    Positioned(
                        left: isLike ? -5 : 20,
                        top: 5,
                        child: Row(children: [
                          Text('点赞',
                              style: TextStyle(
                                color:
                                    isLike ? Colors.transparent : Colors.blue,
                                fontSize: 18,
                              )),
                          Icon(
                            Icons.arrow_upward,
                            color: isLike ? Colors.white : Colors.blue,
                            size: 25,
                          )
                        ]))
                  ]),
                  onPressed: () {
                    setState(() {
                      isLike = !isLike;
                    });
                  },
                ),
              ),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              IconButton(
                  iconSize: 35,
                  onPressed: () {},
                  icon: const Icon(Icons.favorite)),
              const Spacer(),
              IconButton(
                  iconSize: 35,
                  onPressed: () {
                    setState(() {
                      isCommentPanelOpen = !isCommentPanelOpen;
                    });
                    // _showDialog(context);
                  },
                  icon: const Icon(Icons.chat_bubble)),
              const Spacer(),
              IconButton(
                  iconSize: 35,
                  onPressed: () {},
                  icon: const Icon(Icons.share)),
              const Spacer(),
              const Spacer(),
            ],
          ),
        ));
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: isCommentPanelOpen
              ? (MediaQuery.of(context).size.height - 155) * 0.4
              : (MediaQuery.of(context).size.height - 155) * 1,
          width: MediaQuery.of(context).size.width,
          child: _buildListBody(context, widget.post),
        ),
      ],
    );
  }

  Widget _buildListBody(
      BuildContext context, Post item) {
    List<Widget> children = [];
    children
      // ..add(_buildTitle(context, item))
      // ..add(const SizedBox(
      //   height: 12,
      // ))
      ..add(UserProfileWidget(
        nickname: item.nickname, creatorId: item.userId,created: item.created,),)
      ..add(Container(
        padding: const EdgeInsets.only(left: 20, top: 0, bottom: 10),
        child: Text(
          // 加入蓝色小字体 item.likes.toString()人赞同了该回答
          '${item.support_num}人赞同了该回答',
          style:const TextStyle(
            color: Colors.blue,
            fontSize: 12,
          )
        ),
      ))
      ..add(const Divider(
        height: 1,
        color: Colors.grey,))
      ..add(Container(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Text(
            item.content,
            style: Theme.of(context).primaryTextTheme.bodyLarge,
          ),
        ),
      ))
      ..add(const Divider(
        height: 1,
        color: Colors.grey,))
      ..add(
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: Text(
            '评论:',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineLarge
                ?.copyWith(fontSize: 15),
          ),
        ),
      )
      ..add(const SizedBox(
        height: 12,
      ));
    if (item.comments.isEmpty) {
      children.add(const SizedBox(
        height: 50,
      ));
      children.add(_buildNoCommentPageBody(context));
      return ListView(children: children);
    }
    print('item.comments');
    print(item.comments);
    final commentsList =
        item.comments.map((kid) => Comment(comment: commentModel.Comment.fromDbMap(kid))).toList();

    children.addAll(commentsList);
    return ListView(children: children);
  }

  Widget _buildTitle(BuildContext context, Post item) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        item.title,
        style: Theme.of(context)
            .primaryTextTheme
            .headlineLarge
            ?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNoCommentPageBody(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(50),
      child: Center(
          child: Text(
        "There has been no comment on the news",
        style: Theme.of(context)
            .primaryTextTheme
            .headlineLarge
            ?.copyWith(fontSize: 20, color: Colors.white),
      )),
    );
  }
}

class UserProfileWidget extends StatefulWidget {
  final String nickname;
  final String creatorId;
  final String created;
  UserProfileWidget({required this.nickname, required this.creatorId, required this.created});

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  bool isFollowed = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20,right: 20, top: 10, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: CircleAvatar(
              child: cni.CachedNetworkImage(
                imageUrl:
                    "${gv.ip}/api/user/downloadavatar?name=${widget.creatorId}.jpg",
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
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nickname,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.created.toString().substring(0,16),
                    style: const TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
          IconButton(
            iconSize: 40,
            // padding: EdgeInsets.all(10), // 内边距10
            constraints: const BoxConstraints(
                minWidth: 100, maxWidth: 150), // 宽度在50-70之间
            icon: Stack(children: [
              Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                    color: isFollowed ? Colors.lightBlue : Colors.grey,
                    borderRadius: BorderRadius.circular(20)),
              ),
              Positioned(
                  left: isFollowed ? 15 : 20,
                  top: 9,
                  child: Row(children: [
                    Text(isFollowed ? '已关注': '+关注',
                        style: TextStyle(
                          color:
                          isFollowed ? Colors.white : Colors.blue,
                          fontSize: 15,
                        )),
                  ]))
            ]),
            onPressed: () {
              setState(() {
                isFollowed = !isFollowed;
              });
            },
          ),
        ],
      ),
    );
  }
}

class CommentPanel extends StatefulWidget {
  final VoidCallback onClose;
  final int postId;
  final bloc;
  CommentPanel({required this.onClose, required this.postId, this.bloc});

  @override
  State<CommentPanel> createState() => _CommentPanelState();
}

class _CommentPanelState extends State<CommentPanel> {
  final double _dragDistanceThreshold = 10;

  bool isSend  = false;
  final TextEditingController textEditingController = TextEditingController();
  void sendComment() {
    String commentText = textEditingController.text;
    post(commentText);
    print(commentText);
    print('发送');
    setState(() async{
      isSend = true;
      widget.bloc.clearCache();
      widget.bloc.fetchTopIds();
    });
  }
  @override
  void dispose(){
    textEditingController.dispose();
    super.dispose();
  }

  void post(String commentText) async {
    try{
    String result = await CommentApiService().createComment(
          widget.postId,
        commentText,);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
        ),
      );
    textEditingController.text = '';
      print(result);
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("请填写动态类型、标题及内容"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        print("detial.delta.dy = ${details.delta.dy}");
        if (details.delta.dy > _dragDistanceThreshold) {
          widget.onClose();
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.only(top: 30),
            child: const Text(
              '评论',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 1.0,
                widthFactor: 1.0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: chatPrimaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20), // 右上角为圆角
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: CircleAvatar(
                              child: cni.CachedNetworkImage(
                                imageUrl:
                                "${gv.ip}/api/user/downloadavatar?name=${
                                CustomAuth.currentUser.uid
                                }.jpg",
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
                          const SizedBox(width: 10),
                          Expanded(    // 中间评论输入框
                            child: SizedBox(
                              height: 50.0,
                              child: TextField(
                                controller: textEditingController,
                                decoration: const InputDecoration(
                                  hintText: '评论千万条，友善第一条...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(25),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              sendComment();
                            },
                            child: Ink(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: const IconButton(
                                icon: Icon(Icons.send),
                                iconSize: 40,
                                color: Colors.blue,
                                onPressed: null, // 设置为null，以便在InkWell中处理tap手势
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
