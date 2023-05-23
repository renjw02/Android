import 'package:flutter/material.dart';
import 'package:frontend/screens/feeds/more_types_screen.dart';
import '../../Bloc/feeds_bloc_provider.dart';
import '../../utils/colors.dart';
// import '../widgets/item_tile.dart';
import 'feeds_list_screen.dart';
import '../../utils/global_variable.dart';

class FeedsScreen extends StatefulWidget {
  FeedsScreen({super.key, required this.cateFilters, required this.timeFilters, required this.sortFilters});
  late List<String> cateFilters;
  late List<String> timeFilters;
  late List<String> sortFilters;

  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List tabs = ["all", "top", "hot", "follow"];

  @override
  void initState() {
    super.initState();
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
      setState(() {
        widget.cateFilters = result['cateFilters'];
        widget.timeFilters = result['timeFilters'];
        widget.sortFilters = result['sortFilters'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final bloc = FeedsBlocProvider.of(context);
    // bloc.fetchTopIds();
    return Scaffold(
      appBar: AppBar(
        title: const Text('校园论坛'),
        backgroundColor:chatPrimaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            margin: const EdgeInsets.only(right:5,left: 0,top: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    child: TabBar(
                      controller: _tabController,
                      indicator: ShapeDecoration(
                          color: chatAccentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      tabs: tabs.map((e) => Tab(text: e)).toList(),
                      labelStyle:
                          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    // 处理按钮点击事件
                    //跳转到MoreTypesScreen
                    _navigateToMoreTypesScreen();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: mobileBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                        right:5,left: 5,top: 10,bottom: 10
                    ),
                    // margin: const EdgeInsets.only(right:0,left: 10,top: 10),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'More',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: mobileBackgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                  )),
              child: TabBarView(
                controller: _tabController,
                children: tabs.map((e) {
                  return FeedsBlocProvider(
                    key: ValueKey(e),
                    filter: stringToNewsFilter(e),
                    child: Center(child: FeedsListScreen(e: e)),
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
