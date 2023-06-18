import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../Bloc/feeds_bloc_provider.dart';
import '../../widgets/feed_card.dart';


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
      if (kDebugMode) {
        print("onRefresh");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("FeedsListScreen build");
    }
    _bloc = FeedsBlocProvider.withKeyOf(context, ValueKey(widget.e));
    _bloc.fetchIdsByKeyWords(widget.keywords);
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
                    return FeedCard(
                      snapshot.data![index],
                      creatorId: creatorSnapshot.data![index],
                      onRefreshBloc: _bloc,
                    );
                  });
            },
          );
        });
  }

  Widget refreshWidget(Widget child, FeedsBloc bloc,VoidCallback setTheState) {
    return RefreshIndicator(
        child: child,
        onRefresh: () async {
          await _bloc.clearCache();
          _bloc.fetchIdsByKeyWords(widget.keywords);
          setTheState();
        });
  }
}
