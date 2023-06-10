import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart' as async;
import 'package:frontend/models/user.dart' as model;
import 'package:frontend/screens/feeds/feeds_detail_screen.dart';
import 'package:frontend/widgets/Avatar.dart';
import 'package:frontend/widgets/video_component.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../Auth/customAuth.dart';
import '../Bloc/comments_bloc_provider.dart';
import '../Bloc/feeds_bloc_provider.dart';
// import '../blocs/comments_bloc_provider.dart';
import '../models/post.dart';
import '../providers/user_provider.dart';
import '../resources/post_methods.dart';
import '../screens/profile_screen.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';
import '../utils/utils.dart';
import 'like_animation.dart';
// import '../screens/feeds_detail_screen.dart';


class FeedCard extends StatefulWidget {
  final int id;
  final int creatorId;
  final FeedsBloc onRefreshBloc;
  const FeedCard(this.id, {super.key, required this.creatorId, required this.onRefreshBloc});

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
  late int feedId;
  late String feedTitle;
  late String feedContent;
  late String feedCreatorId;
  late String feedCreatorNickName;
  late String feedCreatedAt;
  late int feedType;
  late int feedFontSize;
  late String feedFontColor;
  late String feedFontWeight;
  late int feedSupportNum;
  late List<dynamic> feedSupportList;
  late int feedCommentNum;
  late List<dynamic> feedCommentList;
  late int feedStarNum;
  late List<dynamic> feedStarList;
  @override
  void initState() {
    super.initState();

    // Future.delayed(const Duration(milliseconds: 200))
    //     .then((_) => _animationOpacity = 1);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = FeedsBlocProvider.of(context);
    //final model.User currentUser = Provider.of<UserProvider>(context).getUser;
    final model.User currentUser = CustomAuth.currentUser;
    final width = MediaQuery.of(context).size.width;
    // final commentsBloc = CommentsBlocProvider.withKeyOf(context, ValueKey(widget.id));
    // print(bloc.newFilter);
    // bloc.fetchTopIds();
    bloc.fetchItems(widget.id);
    // print("bloc.fetchItems(widget.id)");

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
              {
                print("itemSnapshot.data!.comment_num");
                print(itemSnapshot.data!.comment_num);
                return _buildItemTile(context, itemSnapshot, currentUser, width, bloc);
              }
            });
      },
    );
  }

  Widget _buildItemTile(BuildContext context, AsyncSnapshot<Post> snap,
      model.User currentUser, double width,  FeedsBloc bloc) {
    print("currentUser.following");
    print(currentUser.following);
    print(currentUser.following.runtimeType);
    feedId = snap.data!.id;
    feedTitle = snap.data!.title;
    feedContent = snap.data!.content;
    feedCreatorId = snap.data!.userId.toString();
    feedCreatorNickName = snap.data!.nickname.toString();
    feedCreatedAt = snap.data!.created.toString();
    feedType = snap.data!.type;
    feedFontSize = snap.data!.font_size;
    feedFontColor = snap.data!.font_color;
    feedFontWeight = snap.data!.font_weight;
    feedSupportNum = snap.data!.support_num;
    feedSupportList = snap.data!.supportList;
    feedCommentNum = snap.data!.comment_num;
    feedCommentList = snap.data!.comments;
    feedStarNum = snap.data!.star_num;
    feedStarList = snap.data!.starList;
    print(feedCreatorId);

    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
        color: mobileBackgroundColor,
        borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
      ),
      child:
      GestureDetector(
      child:Column(
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
                  text: feedTitle,
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
                UserAvatar(
                  userId: feedCreatorId, width: 32,height: 32,
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
                          feedCreatorNickName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          feedCreatedAt.substring(0,16),
                          style: const TextStyle(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                currentUser.following.contains(feedCreatorId)?
                Text(
                  "已关注",
                  style: const TextStyle(
                    color: primaryColor,
                  ),
                ):Container(),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 18,
                    right: 18,
                  ),
                  child:
                  Text(
                    types[feedType].toString(),
                    style: const TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                ),
                // feedCreatorId == currentUser.uid
                //     ? SizedBox(width: 0) : SizedBox(width: 30),
                // feedCreatorId == currentUser.uid
                //     ? IconButton(
                //         onPressed: () {
                //           showDialog(
                //             useRootNavigator: false,
                //             context: context,
                //             builder: (context) {
                //               return Dialog(
                //                 child: ListView(
                //                     padding: const EdgeInsets.only(
                //                         top: 16),
                //                     shrinkWrap: true,
                //                     children: [
                //                       'Delete',
                //                     ]
                //                         .map(
                //                           (e) => InkWell(
                //                               child: Container(
                //                                 padding:
                //                                     const EdgeInsets.symmetric(
                //                                         vertical: 12,
                //                                         horizontal: 16),
                //                                 child: Text(e),
                //                               ),
                //                               onTap: () {
                //                                 // deletePost(
                //                                 //   snap.data!.id.toString(),
                //                                 // );
                //                                 // remove the dialog box
                //                                 Navigator.of(context).pop();
                //                               }),
                //                         )
                //                         .toList()),
                //               );
                //             },
                //           );
                //         },
                //         icon: const Icon(Icons.more_vert),
                //       )
                //     : Container(),
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
                  text: feedContent,
                  style: TextStyle(
                      fontSize: feedFontSize.toDouble(),
                      color: colors[feedFontColor],
                      fontWeight: weights[feedFontWeight]),
                ),
              ),
            )
          ]),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () async {
              // String res = await postMethods().supportPost(
              //   //TODO
              //   snap.data!.id,
              //   currentUser.uid,
              //   snap.data!.supportList,
              // );
              String res = await bloc.supportPost(
                //TODO
                feedId,
                currentUser.uid,
                feedSupportList,
              );
              setState(() {
                if (res == "Success") {
                  feedSupportNum++;
                  if (kDebugMode) {
                    print("support success");
                    print(feedSupportList);
                  }
                } else{
                  //TODO
                  feedSupportNum--;
                }
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // buildImages(photo),
                if (snap.data!.images.isNotEmpty)
                  MediaList(
                    imageUrls: snap.data!.images.map((dynamic) => dynamic.toString()).toList(), videoUrls: snap.data!.videos.map((dynamic) => dynamic.toString()).toList(),
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
            margin: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
            ),
            child: Row(
              children: <Widget>[
                LikeAnimation(
                  isAnimating: feedSupportList.map((dynamic) => dynamic.toString()).toList().contains(currentUser.uid),
                  smallLike: true,
                  child: IconButton(
                    icon: feedSupportList.map((dynamic) => dynamic.toString()).toList()
                            .contains(currentUser.uid) //判断是否点赞
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.favorite_border,
                          ),
                    onPressed: () async {
                      String res = await bloc.supportPost(
                        feedId,
                        currentUser.uid,
                        feedSupportList,
                      );
                      if (kDebugMode) {
                        print(feedSupportList);
                      }
                      if (res == "Success") {
                        feedSupportNum++;
                      } else{
                        //TODO
                        feedSupportNum--;
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
                      '${feedSupportList.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                IconButton(
                  icon: const Icon(
                    Icons.comment_outlined,
                  ),
                  onPressed: ()async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FeedsDetailScreen(id:  widget.id, post: snap.data!, onRefreshBloc: widget.onRefreshBloc),
                      ),
                    );
                    if (result != null) {
                      setState(() {});
                    }
                  },
                ),
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '$feedCommentNum',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                IconButton(
                    //转发按钮
                  icon: const Icon(
                    Icons.share,
                  ),
                  onPressed: () async {
                    await Share.share(
                    "${feedTitle}\n信息来自flutter应用",);
                  }
                ),
                Expanded(
                    child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: //feedStarList.contains(currentUser.uid)
                      feedStarList.map((dynamic) => dynamic.toString()).toList()
                        .contains(currentUser.uid)
                        ? const Icon(
                            Icons.star,
                            color: Colors.red,
                          )
                        : const Icon(Icons.star_border),
                    onPressed: () async {
                      await bloc.starPost(
                        feedId,
                        currentUser.uid,
                        feedStarList,
                        feedTitle,
                      );
                      setState(() {});
                      print(feedStarList);
                      if (kDebugMode) {
                        print(feedStarList);
                      }
                      setState(() {});
                    },
                  ),
                ))
              ],
            ),
          ),
        ],
      ),
      onTap: ()async{
          // CommentsBlocProvider.of(context).fetchItemWithComments(widget.id);
          // commentsBloc.fetchItemWithComments(widget.id);

          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FeedsDetailScreen(id:  widget.id, post: snap.data!, onRefreshBloc: widget.onRefreshBloc),
            ),
          );
        if (result != null) {

          setState(() {});
        }
      },
      )
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
    return Card(
      child: Container(
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
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
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
      ),
    );
  }
}

class MediaList extends StatelessWidget {
  final List<String> imageUrls;
  final List<String> videoUrls;

  const MediaList({
    Key? key,
    required this.imageUrls,
    required this.videoUrls
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalMedia = imageUrls.length + videoUrls.length;
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
        itemCount: totalMedia,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          if (index < imageUrls.length) {
            final imageUrl = imageUrls[index];
            if (imageUrl.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  httpHeaders: {
                    'Authorization': CustomAuth.currentUser.jwt,
                  },
                  placeholder: (context, url) => const Center( child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              );
            }else {
              return const SizedBox(
                width: 120,
                height: 60,
              );
            }
          } else {
            index -= imageUrls.length;
            final videoUrl = videoUrls[index];
            // final posterUrl = videoUrl.thumbnail;
            return  Center(
              child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Center(
                        child: VideoComponent(
                          videoUrl: videoUrl,
                          // canFullScreen: false,
                        ),
                      ),
                    ),
                    // const Center(
                    //   child: Icon(
                    //     Icons.play_circle_filled,
                    //     size: 20,
                    //     color: Colors.white,
                    //   ),
                    // )
                  ],
              ),
            );
          }
        },
      ),
    );
  }
}