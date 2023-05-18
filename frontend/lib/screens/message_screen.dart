import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Bloc/bloc_provider.dart';
import '../Bloc/contactsBloc.dart';
import '../Bloc/noticesBloc.dart';
import '../models/querySnapshot.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';
import '../widgets/contact_user_card.dart';
class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);
  @override
  _MessageScreenState createState() => _MessageScreenState();
}
class _MessageScreenState extends State<MessageScreen>  with SingleTickerProviderStateMixin{
  late TabController _tabController;
  List tabs = ["全部", "通知", "私信"];
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

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
    final bloc = ContactsBloc();
    bloc.submitQuery();
    return BlocProvider<ContactsBloc>(
      key: UniqueKey(),//UniqueKey()是一个flutter提供的用于生成唯一key的类，它的原理是通过时间戳来生成key，所以每次生成的key都是不同的，这样就可以保证每次生成的key都是唯一的。
      bloc: bloc,
      child: Scaffold(
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
                        isShowUsers = true;
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

        // body:TabBarView(
        //   controller: _tabController,
        //   children: tabs.map((e) {
        //     return NoticesList(
        //       e: e,
        //       child: Container(
        //         alignment: Alignment.center,
        //         child: Text(e, textScaleFactor: 5),
        //       ),
        //     );
        //   }).toList().cast<Widget>(),
        // ),
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
                      return ContactsList(
                        e: e,
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(e, textScaleFactor: 5),
                        ),
                      );
                    }).toList().cast<Widget>(),
                  ),
              ),
            ),
          ],
        )
      ),
    );
  }
}


class ContactsList extends StatefulWidget {
  final Widget child;
  final String e;
  const ContactsList({Key? key, required this.child, required this.e}) : super(key: key);

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final bloc = NoticesBloc();
    final width = MediaQuery.of(context).size.width;
    bloc.submitQuery(widget.e);
    print("NoticesList build");
    print(widget.e);
    //拿到传入的text


    super.build(context);
    // return widget.child;
    return Container(
      padding: const EdgeInsets.symmetric(vertical:10,horizontal: 20),
      child: BlocProvider<NoticesBloc>(
        key: UniqueKey(),//UniqueKey()是一个flutter提供的用于生成唯一key的类，它的原理是通过时间戳来生成key，所以每次生成的key都是不同的，这样就可以保证每次生成的key都是唯一的。
        bloc: bloc,
        child:StreamBuilder(
          stream: bloc?.queryStream,
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
                  String returnMsg = await bloc.createNotice(widget.e, "content");
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
                      bloc?.removeNotice(snapshot.data?.docs[index].data()["noticeId"]); // 调用 bloc 的 removeNotice 函数
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
