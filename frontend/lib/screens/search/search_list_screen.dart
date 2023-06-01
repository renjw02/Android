import 'package:flutter/material.dart';
import 'package:frontend/Auth/customAuth.dart';
import 'package:frontend/Bloc/comments_bloc_provider.dart';
import '../../Bloc/feeds_bloc_provider.dart';
import '../../widgets/feed_card.dart';
// import '../widgets/item_tile.dart';

class SearchListScreen extends StatefulWidget {
  const SearchListScreen({super.key, required this.e, required this.keywords});
  final String e;
  final String keywords;
  @override
  State<SearchListScreen> createState() => _SearchListScreenState();
}

class _SearchListScreenState extends State<SearchListScreen> {
  Map<String,String> orderByWhat = {
    "点赞量高优先": "post.support_num",
    "评论量高优先": "post.comment_num",
  };
  Map<String,int> type = {
    "校园资讯": 1,
    "二手交易": 2,
  };

  late FeedsBloc _bloc;
  onRefresh() {
    setState(() {
      print("onRefresh");
    });
  }

  @override
  Widget build(BuildContext context) {
    print("FeedsListScreen build");
    _bloc = FeedsBlocProvider.withKeyOf(context, ValueKey(widget.e));
    _bloc.fetchIdsByKeyWords(widget.keywords);
    // _bloc.fetchIdsByRules(
    //     1 ,
    //     10,
    //     widget.e == "我的帖子" ? int.parse(widget.uid) : 0 ,
    //     widget.sortFilters.length ==1?  orderByWhat[widget.sortFilters[0]] : null,
    //     widget.cateFilters.length == 1 ?type[widget.cateFilters[0]]!: 0  ,
    //     widget.e == "关注" ? true : null,
    //     widget.e == "热度"? true : null);
    return Center(child: refreshWidget(_buildList(_bloc), _bloc,onRefresh));
  }

  Widget _buildList(FeedsBloc bloc) {
    return StreamBuilder(
        stream: bloc.userIds,
        builder:
            (BuildContext context, AsyncSnapshot<List<int>> creatorSnapshot) {
          return StreamBuilder(
            stream: bloc.topIds,
            builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        backgroundColor: Colors.pinkAccent,
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Waiting for data...',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return CommentsBlocProvider(
                        key: ValueKey(snapshot.data![index]),
                        child: FeedCard(
                          snapshot.data![index],
                          creatorId: creatorSnapshot.data![index],
                          onRefreshBloc: _bloc,
                        ));
                    // return const Text(
                    //   'Hello, world!',
                    //   textDirection: TextDirection.ltr,
                    // );
                  });
            },
          );
        });
  }

  Widget refreshWidget(Widget child, FeedsBloc bloc,VoidCallback setTheState) {
    return RefreshIndicator(
        child: child,
        onRefresh: () async {
          // print("onRefresh");
          await _bloc.clearCache();
          _bloc.fetchIdsByKeyWords(widget.keywords);
          // await _bloc.fetchIdsByRules(
          //     1 ,
          //     10,
          //     widget.e == "我的帖子" ? int.parse(widget.uid) : 0 ,
          //     widget.sortFilters.length ==1?  orderByWhat[widget.sortFilters[0]] : null,
          //     widget.cateFilters.length == 1 ?type[widget.cateFilters[0]]!: 0  ,
          //     widget.e == "关注" ? true : null,
          //     widget.e == "热度"? true : null);
          setTheState();
        });
  }
}
