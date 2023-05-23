import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:frontend/utils/colors.dart';

import '../../Auth/customAuth.dart';
import '../../Bloc/feeds_bloc.dart';
import '../../Bloc/feeds_bloc_provider.dart';
import '../../models/post.dart';

import '../../widgets/comment.dart';

import '../../models/comment.dart' as commentModel;
import '../../widgets/Avatar.dart' as avatar;
import 'comment_panel.dart';

class FeedsDetailScreen extends StatefulWidget {
  final int id;
  final Post post;
  final FeedsBloc onRefreshBloc;
  const FeedsDetailScreen({super.key, required this.id, required this.post, required this.onRefreshBloc});

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
  void _viewFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Stack(
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  httpHeaders: {
                    'Authorization': CustomAuth.currentUser.jwt,
                  },
                  placeholder: (context, url) =>
                  const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 5, left: 5),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      //设置图标的大小
                      iconSize: 35,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // final bloc = FeedsBlocProvider.of(context);
    // timeDilation = 0.5;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.post.title),
        ),
        body: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: isCommentPanelOpen
              ? CommentPanel(onClose: _onScroll, post: widget.post, onRefreshBloc: widget.onRefreshBloc)
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
                      minWidth: 105, maxWidth: 150), // 宽度在50-70之间
                  icon: Stack(children: [
                    Container(
                      width: 105,
                      height: 32,
                      decoration: BoxDecoration(
                          color: isLike ? Colors.lightBlue : Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    Positioned(
                        left: isLike ? -5 : 20,
                        top: 2,
                        child: Row(children: [
                          Text('点赞',
                              style: TextStyle(
                                color:
                                    isLike ? Colors.transparent : Colors.blue,
                                fontSize: 15,
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

        Expanded(
          // height: isCommentPanelOpen
          //     ? (MediaQuery.of(context).size.height - 155) * 0.4
          //     : (MediaQuery.of(context).size.height - 155) * 1,
          // width: MediaQuery.of(context).size.width,
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
      ..add (SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 0.9,
        child: PageView.builder(
          itemCount: item.images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _viewFullScreenImage(item.images[index]);
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                child: CachedNetworkImage(
                  imageUrl: item.images[index],
                  httpHeaders: {
                    'Authorization': CustomAuth.currentUser.jwt,
                  },
                  // placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            );
          },
          pageSnapping: true,
        ),
      ))
      ..add(const SizedBox(
        height: 15,))
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
            child: avatar.UserAvatar(
              userId: widget.creatorId,
              width: 50,
              height: 50,
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
                    color: isFollowed ? Colors.lightBlue : Colors.white,
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

