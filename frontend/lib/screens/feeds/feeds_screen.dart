import 'package:flutter/material.dart';
import 'package:frontend/Auth/customAuth.dart';
import 'package:frontend/screens/feeds/more_types_screen.dart';
import '../../Bloc/feeds_bloc_provider.dart';
import '../../utils/colors.dart';
// import '../widgets/item_tile.dart';
import 'feeds_list_screen.dart';
import '../../utils/global_variable.dart';

class FeedsScreen extends StatefulWidget {
  FeedsScreen(
      {super.key,
      required this.cateFilters,
      required this.timeFilters,
      required this.sortFilters});
  late List<String> cateFilters;
  late List<String> timeFilters;
  late List<String> sortFilters;

  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List tabs = ["全部", "热度", "关注"];
  List filteredTabs = ["全部", "热度", "关注", "已筛选"];
  late bool isFilter;
  @override
  void initState() {
    super.initState();
    isFilter = false;
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    // 释放资源
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToMoreTypesScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MoreTypesScreen(),
      ),
    );
    if (result != null) {
      isFilter = true;
      widget.cateFilters = result['cateFilters'];
      widget.timeFilters = result['timeFilters'];
      widget.sortFilters = result['sortFilters'];
      // _tabController.animateTo(3);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // final bloc = FeedsBlocProvider.of(context);
    // bloc.fetchTopIds();
    return Scaffold(
      appBar: AppBar(
        title: const Text('校园论坛'),
        backgroundColor: chatPrimaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            margin: const EdgeInsets.only(right: 20, left: 20, top: 10),
            child: isFilter
                ?
            Row(
                  children: [
                    ClosableTab(
                        text: "已筛选",
                        onClose: () {
                          // 取消过滤条件的逻辑
                          print('Close 已筛选');
                          widget.cateFilters = [];
                          widget.timeFilters = [];
                          widget.sortFilters = [];
                          isFilter = false;
                          // 刷新页面
                          setState(() {
                            _tabController.animateTo(0);
                          });
                          print('Close 已筛选');
                        }),
                    widget.cateFilters.isEmpty ? Container()  :RuleTab(text: widget.cateFilters[0]),
                    widget.cateFilters.length <= 1 ? Container()  :RuleTab(text: widget.cateFilters[1]),
                    widget.timeFilters.isEmpty ? Container()  :RuleTab(text: widget.timeFilters[0]),
                    widget.sortFilters.isEmpty ? Container()  :RuleTab(text: widget.sortFilters[0]),
                  ],
                )
                :
            Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.only(right: 20),
                          child: TabBar(
                            controller: _tabController,
                            indicator: ShapeDecoration(
                                color: chatAccentColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            tabs: tabs.map((e) => Tab(text: e)).toList(),
                            labelStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      MoreTypeTab(
                          text: '筛选',
                          onMore: () {
                            _navigateToMoreTypesScreen();
                          }),
                    ],
                  ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: mobileBackgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: isFilter
                  ? FeedsBlocProvider(
                      key: ValueKey('已筛选'),
                      filter: stringToNewsFilter('已筛选'),
                      child: Center(
                          child: FeedsListScreen(
                        e: '已筛选',
                        cateFilters: widget.cateFilters,
                        timeFilters: widget.timeFilters,
                        sortFilters: widget.sortFilters,
                            uid:CustomAuth.currentUser.uid,
                      )),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: tabs.map((e) {
                        return FeedsBlocProvider(
                          key: ValueKey(e),
                          filter: stringToNewsFilter(e),
                          child: Center(
                              child: FeedsListScreen(
                            e: e,
                            cateFilters: widget.cateFilters,
                            timeFilters: widget.timeFilters,
                            sortFilters: widget.sortFilters,
                                uid:CustomAuth.currentUser.uid,
                          )),
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClosableTab extends StatelessWidget {
  final String text;
  final VoidCallback onClose;

  ClosableTab({required this.text, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Center(
        child: Row(
          children: [
            Tab(text: text),
            Icon(Icons.close, size: 18),
          ],
        ),
      ),
    );
  }
}

class RuleTab extends StatelessWidget {
  final String text;

  RuleTab({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child:Container(
        margin: const EdgeInsets.only(right: 5, left: 5 ),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Tab(
              text: text,),
      )
    );
  }
}

class MoreTypeTab extends StatelessWidget {
  final String text;
  final VoidCallback onMore;

  MoreTypeTab({required this.text, required this.onMore});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onMore,
      child: Center(
        child: Row(
          children: [
            Tab(text: text),
            Icon(Icons.arrow_forward_ios, size: 15),
          ],
        ),
      ),
    );
  }
}
