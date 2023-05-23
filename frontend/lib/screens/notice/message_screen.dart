import 'dart:async';

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
        width > webScreenSize ? webBackgroundColor : chatPrimaryColor,
        appBar: width > webScreenSize
            ? null
            : AppBar(
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu),
                ),
              ],
              backgroundColor: chatPrimaryColor,
              centerTitle: false,
              title: Container(
                margin: EdgeInsets.all(10.0),
                height: 35.0,
                child: Form(
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: '搜索私信',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                    ),
                    onFieldSubmitted: (String _) {
                      setState(() {
                        // isShowUsers = true;
                      });
                      print(_);
                    },
                  ),
                ),
              ),
              // bottom: TabBar(
              //   controller: _tabController,
              //   tabs: tabs.map((e) => Tab(text: e)).toList(),
              // ),
            ),
        body:Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 16),
              height: 75,
              color: chatPrimaryColor,
              child: TabBar(
                controller: _tabController,
                indicator: ShapeDecoration(
                    color: chatAccentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))
                ),
                tabs: tabs.map((e) => Tab(text: e)).toList(),
                labelStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
  late StreamController<QuerySnapshot> _queryController = StreamController<QuerySnapshot>();
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
    // _streamController = CustomStore.instance.collection<QuerySnapshot>("posts");
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
    print("removeNotice");
    String result = await db.DataBaseManager().removeNotice(noticeId);
    if(result == "Success"){
      submitQuery(_type);
      print("删除成功");
    }else{
      print("删除失败");
    }
    return result;
  }

  Future<String> createNotice(String str_type, String content) async  {
    int type = 0;
    if (str_type == "通知" || str_type == "全部") {
      type = 0;
    } else if (str_type == "私信") {
      type = 1;
    } else if (str_type == "已认证") {
      type = 2;
    } else if (str_type == "提及") {
      type = 3;
    } else {
      type = 4;
    }
    String returnMsg = await db.DataBaseManager().createNotice(type, content);
    if(returnMsg == "Success"){
      submitQuery(_type);
      print("创建成功");
    }else{
      print("创建失败");
    }

    return returnMsg;

    // _queryController.sink.add(querySnapshot);
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
          querySnapshot.docs = querySnapshot.docs.where((element) => element.data()['noticeType'] == 0).toList();
          _queryController.sink.add(querySnapshot);
          break;
        }
      case "私信":
        {
          // QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();
          // //筛选出私信
          // querySnapshot.docs = querySnapshot.docs.where((element) => element.data()['noticeType'] == 1).toList();
          // _queryController.sink.add(querySnapshot);
          QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();
          // 筛选出私信
          querySnapshot.docs = querySnapshot.docs.where((element) => element.data()['noticeType'] == 1).toList();

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
      case "已认证":
        {
          QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();
          //筛选出已认证
          querySnapshot.docs = querySnapshot.docs.where((element) => element.data()['noticeType'] == 2).toList();
          _queryController.sink.add(querySnapshot);
          break;
        }
      case "提及":
        {
          QuerySnapshot querySnapshot = await db.DataBaseManager().noticeListQuery();
          //筛选出提及
          querySnapshot.docs = querySnapshot.docs.where((element) => element.data()['noticeType'] == 3).toList();
          _queryController.sink.add(querySnapshot);
          break;
        }
      default:
        {
          print("非法值");
          return;
        }
    }
    _type = type;
  }

  @override
  Widget build(BuildContext context) {
    // final bloc = NoticesBloc();
    final width = MediaQuery.of(context).size.width;
    // bloc.submitQuery(widget.e);
    print("NoticesList build");
    print(widget.e);
    //拿到传入的text


    super.build(context);
    // return widget.child;
    return RefreshIndicator(
      onRefresh: () async {
        submitQuery(widget.e);
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
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    String returnMsg = await createNotice(widget.e, "content");
                    if(returnMsg == "Success"){
                      // 向用户显示信息
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('创建成功')),
                      );
                    }else{
                      // 向用户显示信息
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('创建失败')),
                      );
                    }
                    // 处理按钮点击事件
                  },
                  backgroundColor:  chatAccentColor,
                  child: Icon(Icons.add),
                ),
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
                        if(snapshot.data?.docs[index].data()["noticeType"] == 1){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('私信已删除')),
                          );
                        }
                          //如果是通知，就显示通知删除成功
                        if(snapshot.data?.docs[index].data()["noticeType"] == 0){
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
