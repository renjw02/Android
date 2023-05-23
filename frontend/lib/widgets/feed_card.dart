import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart' as async;
import 'package:frontend/models/user.dart' as model;
import 'package:frontend/screens/feeds_detail_screen.dart';
import 'package:provider/provider.dart';
import '../Auth/customAuth.dart';
import '../Bloc/comments_bloc_provider.dart';
import '../Bloc/feeds_bloc_provider.dart';
// import '../blocs/comments_bloc_provider.dart';
import '../models/post.dart';
import '../providers/user_provider.dart';
import '../resources/textpost_methods.dart';
import '../screens/comments_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';
import '../utils/utils.dart';
import 'like_animation.dart';
// import '../screens/feeds_detail_screen.dart';

class FeedCard extends StatefulWidget {
  final int id;
  final int creatorId;
  const FeedCard(this.id, {super.key, required this.creatorId});

  @override
  _FeedCardState createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard>
    with SingleTickerProviderStateMixin {
  final _asyncMemoize = async.AsyncMemoizer<Post>();
  late final List<String> imageUrls;
  Map<int, String> types = {1: "校园资讯", 2: "二手交易"};
  Map<String, Color> colors = {
    "red": Colors.red,
    "white": Colors.white,
    "yellow": Colors.yellow
  };
  Map<String, FontWeight> weights = {
    "较细": FontWeight.w300,
    "适中": FontWeight.w500,
    "较粗": FontWeight.w700
  };
  bool isLikeAnimating = false;

  @override
  void initState() {
    super.initState();

    // Future.delayed(const Duration(milliseconds: 200))
    //     .then((_) => _animationOpacity = 1);
  }

  deletePost(String postId) async {
    //TODO
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
    final bloc = FeedsBlocProvider.of(context);
    final model.User currentUser = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;
    // final commentsBloc = CommentsBlocProvider.withKeyOf(context, ValueKey(widget.id));
    bloc.fetchItems(widget.id);

    // bloc.fetchUsers(widget.creatorId);

    return StreamBuilder(
      stream: bloc.items,
      builder: (BuildContext context,
          AsyncSnapshot<Map<int, Future<Post>>> itemSnap) {
        switch (itemSnap.connectionState) {
          case ConnectionState.waiting:
            return _defaultNewsContainer();
          default:
        }
        if (!itemSnap.hasData) {
          return _defaultNewsContainer();
        }
        return FutureBuilder(
            future: _futureItem(itemSnap),
            builder: (BuildContext context, AsyncSnapshot<Post> itemSnapshot) {
              if (!itemSnapshot.hasData) return _defaultNewsContainer();
              return _buildItemTile(context, itemSnapshot, currentUser, width, bloc);
            });
      },
    );
  }

  Widget _buildItemTile(BuildContext context, AsyncSnapshot<Post> snap,
      model.User currentUser, double width,  var bloc) {
    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
        color: mobileBackgroundColor,
        borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
      ),
      child: Column(
        children: [
          //分割线
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),
          // Title OF THE POST
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
            ),
            child: RichText(
                text: TextSpan(
                  text: snap.data!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )),
          ),
          // HEADER SECTION OF THE POST
          Container(
            padding: const EdgeInsets.only(
              top: 4,
              left: 16,
              right: 16,
            ).copyWith(right: 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(uid: snap.data!.userId),
                        //const LoginScreen(),
                      ),
                    );
                  },
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl:
                          "$ip/api/user/downloadavatar?name=${snap.data!.userId}.jpg",
                      httpHeaders: {
                        'Authorization': CustomAuth.currentUser.jwt,
                      },
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 18,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snap.data!.nickname.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          snap.data!.created.toString().substring(0,16),
                          style: const TextStyle(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  types[snap.data!.type].toString(),
                  style: const TextStyle(
                    color: secondaryColor,
                  ),
                ),
                snap.data!.userId.toString() == currentUser.uid
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ListView(
                                    padding: const EdgeInsets.only(
                                        top: 16),
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
                                                  snap.data!.id.toString(),
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
          Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 8,
                left: 20,
                right: 20,
              ),
              // child: RichText(
              //     text: TextSpan(
              //   text: snap.data!.title,
              //   style: const TextStyle(
              //     color: Colors.white,
              //     fontWeight: FontWeight.bold,
              //   ),
              // )),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 8,left:20
              ),
              child: RichText(
                text: TextSpan(
                  text: snap.data!.content,
                  style: TextStyle(
                      fontSize: snap.data!.font_size.toDouble(),
                      color: colors[snap.data!.font_color],
                      fontWeight: weights[snap.data!.font_weight]),
                ),
              ),
            )
          ]),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () async {
              String res = await TextPostMethods().supportPost(
                //TODO
                snap.data!.id.toString(),
                currentUser.uid,
                snap.data!.supportList,
              );
              setState(() {
                if (res == "Success") {
                  snap.data!.support_num++;
                  if (kDebugMode) {
                    print(snap.data!.supportList);
                  }
                } else {
                  snap.data!.support_num--;
                }
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // buildImages(photo),
                if (snap.data!.images.isNotEmpty)
                  ImageList(
                    imageUrls: snap.data!.images,
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
                      size: 80,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
            ),
            child: Row(
              children: <Widget>[
                LikeAnimation(
                  isAnimating: snap.data!.supportList.contains(currentUser.uid),
                  smallLike: true,
                  child: IconButton(
                    icon: snap.data!.supportList
                            .contains(currentUser.uid) //判断是否点赞
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.favorite_border,
                          ),
                    onPressed: () async {
                      String res = await TextPostMethods().supportPost(
                        snap.data!.id.toString(),
                        currentUser.uid,
                        snap.data!.supportList,
                      );
                      if (kDebugMode) {
                        print(snap.data!.supportList);
                      }
                      if (res == "Success") {
                        snap.data!.support_num++;
                      } else {
                        snap.data!.support_num--;
                      }
                      setState(() {});
                    },
                  ),
                ),
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${snap.data!.support_num} ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                IconButton(
                  icon: const Icon(
                    Icons.comment_outlined,
                  ),
                  onPressed: () {
                    // CommentsBlocProvider.of(context).fetchItemWithComments(widget.id);
                    // commentsBloc.fetchItemWithComments(widget.id);

                    Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FeedsDetailScreen(id:  widget.id, post: snap.data!,bloc: bloc),
                    ),
                  );
                  },
                ),
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${snap.data!.comment_num}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                IconButton(
                    //转发按钮
                    icon: const Icon(
                      Icons.send,
                    ),
                    onPressed: () {}),
                Expanded(
                    child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: snap.data!.starList.contains(currentUser.uid)
                        ? const Icon(
                            Icons.star,
                            color: Colors.red,
                          )
                        : const Icon(Icons.star_border),
                    onPressed: () {},
                  ),
                ))
              ],
            ),
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: <Widget>[
          //       // DefaultTextStyle(
          //       //   style: Theme.of(context)
          //       //       .textTheme
          //       //       .subtitle2!
          //       //       .copyWith(fontWeight: FontWeight.w800),
          //       //   child: Text(
          //       //     '${widget.snap['support_num']} 点赞',
          //       //     style: Theme.of(context).textTheme.bodyText2,
          //       //   )
          //       // ),
          //
          //       InkWell(
          //         child: Container(
          //           padding: const EdgeInsets.symmetric(vertical: 4),
          //           child: Text(
          //             '查看所有 ${snap.data!.comment_num} 条评论',
          //             style: const TextStyle(
          //               color: blueColor,
          //             ),
          //           ),
          //         ),
          //         onTap: () => Navigator.of(context).push(
          //           MaterialPageRoute(
          //             builder: (context) => CommentsScreen(
          //               postId: snap.data!.id.toString(),
          //             ),
          //           ),
          //         ),
          //       ),
          //       Container(
          //         padding: const EdgeInsets.symmetric(vertical: 4),
          //         child: Text(
          //           // DateFormat.yMMMd()
          //           //     .format(widget.snap['datePublished'].toDate()),
          //           snap.data!.created.toString(),
          //           style: const TextStyle(
          //             color: secondaryColor,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _defaultNewsContainer() {
    if (kDebugMode) {
      print('default news container');
    }

    return Column(
      children: <Widget>[
        ListTile(
          title: Container(
            height: 20,
            color: Colors.blueGrey.withOpacity(0.2),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 40,
                height: 20,
                color: Colors.blueGrey.withOpacity(0.2),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          child: Divider(),
        ),
      ],
    );
  }

  Future<Post> _futureItem(AsyncSnapshot<Map<int, Future<Post>>> snapshot) =>
      _asyncMemoize.runOnce(() async {
        Future<Post>? futureModel = snapshot.data?[widget.id];

        return futureModel!;
      });
  // Future<Post> _futureItem(AsyncSnapshot<Map<int, Future<Post>>> snapshot) =>
  //     Future.value(snapshot.data?[widget.id]);
  // Future<User> _futureUser(AsyncSnapshot<Map<int, Future<User>>> snapshot) =>
  //     _asyncMemoizeUser.runOnce(() async {
  //       Future<User>? futureModel = snapshot.data?[widget.creatorId];
  //       print("futureModel:$futureModel");
  //       return futureModel!;
  //     });
  // Future<User> _futureUser(AsyncSnapshot<Map<int, Future<User>>> snapshot) =>
  //     Future.value(snapshot.data?[widget.creatorId]);
}

class ImageList extends StatelessWidget {
  final List<String> imageUrls;

  const ImageList({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 20.0,
        right: 20.0,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: imageUrls.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          final imageUrl = imageUrls[index];
          if (imageUrl.isNotEmpty) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                httpHeaders: {
                  'Authorization': CustomAuth.currentUser.jwt,
                },
                placeholder: (context, url) => const SizedBox(
                    width: 10, height: 10, child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            );
          } else {
            return const SizedBox(
              width: 120,
              height: 60,
            );
          }
        },
      ),
    );
  }
}
