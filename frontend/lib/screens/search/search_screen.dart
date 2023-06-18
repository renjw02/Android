import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frontend/Auth/customAuth.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/search/search_list_screen.dart';

import '../../Bloc/feeds_bloc_provider.dart';
import '../../models/DocumentSnapshot.dart';
import '../../models/querySnapshot.dart';
import '../../models/user.dart';
import '../../utils/colors.dart';
import '../../utils/global_variable.dart';
import '../feeds/feeds_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> {
  //searchController的作用是用来获取用户输入的内容
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: Container(
            margin: const EdgeInsets.all(10.0),
            height: 35.0,
            child: Form(
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search for a post...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                ),
                onFieldSubmitted: (String _) {
                  setState(() {
                    isShowUsers = true;
                  });
                  if (kDebugMode) {
                    print(_);
                  }
                },
              ),
            ),
          ),
        ),
      body: isShowUsers
          ? FeedsBlocProvider(
        key: const ValueKey('search'),
        child: Center(
            child: SearchListScreen(
              e: 'search',
              keywords: searchController.text,
            )),
      )
          :
      Container(
        margin: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              '热门搜索',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: FeedsBlocProvider(
                key: const ValueKey('热度'),
                child: Center(
                    child: FeedsListScreen(
                      e: '热度',
                      cateFilters: [],
                      timeFilters: [],
                      sortFilters: [],
                      uid:CustomAuth.currentUser.uid,
                    )),
              ),
            ),
          ],
        ),
      )
    );
  }
}