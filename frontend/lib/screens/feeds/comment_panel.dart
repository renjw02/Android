import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Auth/customAuth.dart';
import '../../Bloc/feeds_bloc_provider.dart';
import '../../models/comment.dart' as commentModel;
import '../../widgets/comment.dart';
import '../../models/post.dart';
import '../../resources/web_service/comment_api_service.dart';
import '../../utils/colors.dart';
import '../../widgets/Avatar.dart' as avatar;
class CommentPanel extends StatefulWidget {
  final VoidCallback onClose;
  final FeedsBloc onRefreshBloc;
  Post post;
  CommentPanel({required this.onClose, required this.post, required this.onRefreshBloc});

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
    setState(() {
      widget.post.comments.add({
        "commentId": 0,
        "content": commentText,
        "created": DateTime.now().toString().substring(0,16),
        "id": 16,
        "nickname": CustomAuth.currentUser.nickname,
        "postId": widget.post.id,
        "updated": DateTime.now().toString().substring(0,16),
        "userId": int.parse(CustomAuth.currentUser.uid) ,
      });
      widget.onRefreshBloc.clearCache();
      widget.onRefreshBloc.fetchTopIds();
      widget.onRefreshBloc.fetchItems(widget.post.id);
    });
    // widget.onRefreshBloc.fetchItems(widget.post.id).then((post) {
    //   setState(() {
    //     widget.post.comments.add({
    //       "commentId": 0,
    //       "content": commentText,
    //       "created": DateTime.now().toString().substring(0,16),
    //       "id": 16,
    //       "nickname": CustomAuth.currentUser.nickname,
    //       "postId": widget.post.id,
    //       "updated": DateTime.now().toString().substring(0,16),
    //       "userId": CustomAuth.currentUser.uid,
    //     });
    //     // print("widget.post:${widget.post}");
    //     // print("widget.post.comments:${widget.post.comments}");
    //     // print("post:$post");
    //     // print("post.comments:${post.comments}");
    //     // widget.post = post;
    //     // print("widget.post:${widget.post}");
    //     // print("widget.post.comments:${widget.post.comments}");
    //   });
    // });
  }
  @override
  void dispose(){
    textEditingController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // 滚动到底部时执行的代码
      widget.onClose();
    }
  }

  final double _scrollThreshold = 200.0; // 定义滑动距离阈值
  double _lastOffset = 0.0; // 最近一次滑动到底部的位置
  int _lastTimeStamp = 0; // 最近一次滑动到底部的时间戳

  void _handleScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      print('滑动到底部');
      // 如果滑动到底部
      int currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
      print('currentTimeStamp: $currentTimeStamp');
      if (_lastTimeStamp == 0) {
        // 如果是第一次滑动到底部，记录当前时间戳和滑动位置
        _lastTimeStamp = currentTimeStamp;
        _lastOffset = _scrollController.position.pixels;
      } else {
        // 如果不是第一次滑动到底部，计算时间差和滑动距离差
        int duration = currentTimeStamp - _lastTimeStamp;
        double distance = (_scrollController.position.pixels - _lastOffset).abs();
        print('duration: $duration, distance: $distance');
        if (duration < 1000 && distance > _scrollThreshold) {
          // 如果时间差小于1秒且滑动距离大于阈值，表示用户已经滑动到底部并继续滑动了一段距离，可以触发事件
          _lastTimeStamp = currentTimeStamp;
          _lastOffset = _scrollController.position.pixels;
          _handleLoadMore();
        }
      }
    } else {
      // 如果没有滑动到底部，重置记录的时间戳和滑动位置
      _lastTimeStamp = 0;
      _lastOffset = 0;
    }
  }

  void _handleLoadMore() {
    // 在这里处理触发事件的逻辑
    widget.onClose();
  }

  void post(String commentText) async {
    try{
      String result = await CommentApiService().createComment(
        widget.post.id,
        commentText,);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
        ),
      );
      textEditingController.text = '';

      // await widget.bloc.clearCache();
      // await widget.bloc.fetchTopIds();
      // await widget.bloc.fetchItems(widget.post.id);
      print(result);
    }catch(e){
      print("error");
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("请填写动态类型、标题及内容"),
        ),
      );
    }
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
  @override
  Widget build(BuildContext context) {
    // final of_bloc = FeedsBlocProvider.of(context);
    // print('of_bloc');
    // print(identical(of_bloc, widget.bloc));
    final screenHeight = MediaQuery.of(context).size.height;
    List<Widget> children = [];
    if (widget.post.comments.isEmpty) {
      children.add(const SizedBox(
        height: 50,
      ));
      children.add(_buildNoCommentPageBody(context));
      // return ListView(children: children);
    }else{
      print('item.comments');
      print(widget.post.comments);
      final commentsList =
      widget.post.comments.map((kid) => Comment(comment: commentModel.Comment.fromDbMap(kid))).toList();
      children.addAll(commentsList);
    }


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
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25), // 右上角为圆角
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            // height: screenHeight * 0.6,
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification is ScrollEndNotification && _scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
                                  // 如果滑动到底部，但没有继续滑动，重置记录的时间戳和滑动位置
                                  _lastTimeStamp = 0;
                                  _lastOffset = 0;
                                }
                                return true;
                              },
                              child:  ListView.builder(
                                controller: _scrollController,
                                itemCount: children.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return children[index];
                                },
                              ),
                            ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: avatar.UserAvatar(
                                userId: CustomAuth.currentUser.uid,
                                width: 40,
                                height: 40,
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
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
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
