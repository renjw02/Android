import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../resources/database_methods.dart' as db;
import '../../Bloc/bloc_provider.dart';
import '../../Bloc/contactsBloc.dart';
import '../../Bloc/noticesBloc.dart';
import '../../models/querySnapshot.dart';
import '../../utils/colors.dart';
import '../../utils/global_variable.dart';
import '../../widgets/contact_user_card.dart';
class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);
  @override
  _MessageScreenState createState() => _MessageScreenState();
}
class _MessageScreenState extends State<MessageScreen>  with SingleTickerProviderStateMixin{
  late TabController _tabController;
  List tabs = ["私信", "通知"];
  final TextEditingController searchController = TextEditingController();
  // bool isShowUsers = false;

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
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // bloc.submitQuery();
    return Scaffold(
        backgroundColor:
        width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        appBar: width > webScreenSize
            ? null
            : AppBar(
          title: Center(
            child: const Text(
              '私信与通知',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // AppBar(
        //       actions: [
        //         IconButton(
        //           onPressed: () {},
        //           icon: const Icon(Icons.menu),
        //         ),
        //       ],
        //       backgroundColor: mobileBackgroundColor,
        //       centerTitle: false,
        //       title: Container(
        //         margin: EdgeInsets.all(10.0),
        //         height: 35.0,
        //         child: Form(
        //           child: TextFormField(
        //             controller: searchController,
        //             decoration: InputDecoration(
        //               labelText: '搜索私信',
        //               border: OutlineInputBorder(
        //                 borderRadius: BorderRadius.circular(20.0),
        //               ),
        //               enabledBorder: OutlineInputBorder(
        //                 borderRadius: BorderRadius.circular(20.0),
        //                 borderSide: BorderSide(color: Colors.grey),
        //               ),
        //               focusedBorder: OutlineInputBorder(
        //                 borderRadius: BorderRadius.circular(20.0),
        //                 borderSide: BorderSide(color: Colors.blue),
        //               ),
        //               contentPadding: EdgeInsets.symmetric(vertical: 4.0),
        //             ),
        //             onFieldSubmitted: (String _) {
        //               setState(() {
        //                 // isShowUsers = true;
        //               });
        //               print(_);
        //             },
        //           ),
        //         ),
        //       ),
        //       // bottom: TabBar(
        //       //   controller: _tabController,
        //       //   tabs: tabs.map((e) => Tab(text: e)).toList(),
        //       // ),
        //     ),
        body:Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              height: 55,
              color: mobileBackgroundColor,
              child: TabBar(
                controller: _tabController,
                indicator: ShapeDecoration(
                    color: chatAccentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))
                ),
                tabs: tabs.map((e) => Tab(text: e)).toList(),
                labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                onTap: (index) {
                  setState(() {
                    _tabController.animateTo(index);
                  });
                },
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
                    children:
                    tabs.map((e) {
                      return ContactsList(e: e);
                    }).toList(),

                  ),
              ),
            ),
          ],
      ),
    );
  }
}


class ContactsList extends StatefulWidget {
  final String e;
  const ContactsList({Key? key, required this.e}) : super(key: key);

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> with AutomaticKeepAliveClientMixin {
  late QuerySnapshot _querySnapshot;
  late final StreamController<QuerySnapshot> _queryController = StreamController<QuerySnapshot>();
  late String _type;
  bool isLoading = false;
  // 添加一个刷新方法
  void refresh() {
    setState(() {
    });
  }
  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    super.initState();
    getData();
  }

  getData() async {
    submitQuery(widget.e);
    setState(() {
      isLoading = false;
    });
  }
  void selectQuery(QuerySnapshot querySnapshot) {
    _querySnapshot = querySnapshot;
    _queryController.sink.add(querySnapshot);
  }

  Future<String> removeNotice(int noticeId) async {
    if (kDebugMode) {
      print("removeNotice");
    }
    String result = await db.DataBaseManager().removeNotice(noticeId);
    if(result == "Success"){
      submitQuery(_type);
      if (kDebugMode) {
        print("删除成功");
      }
    }else{
      if (kDebugMode) {
        print("删除失败");
      }
    }
    return result;
  }

  void submitQuery(String type) async {
    //type的值可能是“全部”、“通知”、“私信”或非法值
    //根据type的值选择不同的查询
    switch (type) {
      case "全部":
        {
          QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();

          _queryController.sink.add(querySnapshot);
          break;
        }
      case "通知":
        {
          QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();
          //筛选出通知
          querySnapshot.docs = querySnapshot.docs.where((element) => element.data()['noticeType'] != 0).toList();
          _queryController.sink.add(querySnapshot);
          break;
        }
      case "私信":
        {
          QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();
          // 筛选出私信
          querySnapshot.docs = querySnapshot.docs.where((element) => element.data()['noticeType'] == 0).toList();

          // 将通知按照noticeCreator分组
          Map<String, List<dynamic>> groupedNotices = {};
          for (var doc in querySnapshot.docs) {
            String noticeCreator = doc.data()['noticeCreator'].toString();
            if (!groupedNotices.containsKey(noticeCreator)) {
              groupedNotices[noticeCreator] = [];
            }
            groupedNotices[noticeCreator]?.add(doc);
          }

          // 对每个组中的通知按照时间顺序排序，并只留下最新的通知
          List<dynamic> filteredDocs = [];
          for (var notices in groupedNotices.values) {
            notices.sort((a, b) => b.data()['created'].compareTo(a.data()['created']));
            filteredDocs.add(notices.first);
          }

          querySnapshot.docs = filteredDocs;
          //querySnapshot.docs里的元素按照时间顺序排列
          //最新的私信在最前面
          querySnapshot.docs.sort((a, b) => b.data()['created'].compareTo(a.data()['created']));
          _queryController.sink.add(querySnapshot);
          break;
        }
      default:
        {
          if (kDebugMode) {
            print("非法值");
          }
          return;
        }
    }
    _type = type;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (kDebugMode) {
      print("NoticesList build");
      print(widget.e);
    }
    //拿到传入的text


    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        submitQuery(widget.e);
        setState(() {});
        },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical:10,horizontal: 20),
        child: StreamBuilder(
            stream: _queryController.stream,
            builder: (context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Scaffold(
                body:ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) => Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: width > webScreenSize ? width * 0.3 : 0,
                      vertical: width > webScreenSize ? 15 : 0,
                    ),
                    child: ContactUserCard(
                      snap: snapshot.data?.docs[index].data(),
                      onRemoved: () {
                        removeNotice(snapshot.data?.docs[index].data()["noticeId"]); // 调用 bloc 的 removeNotice 函数
                        //弹窗告诉用户删除成功
                          //如果是私信，就显示私信已删除
                        if(snapshot.data?.docs[index].data()["noticeType"] == 0){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('私信已删除')),
                          );
                        }
                          //如果是通知，就显示通知删除成功
                        if(snapshot.data?.docs[index].data()["noticeType"] == 1){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('通知删除成功')),
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
        ),
      ),
    );
  }


  @override
  bool get wantKeepAlive => true;
}
