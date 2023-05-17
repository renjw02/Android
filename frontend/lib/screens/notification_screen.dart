import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Bloc/bloc_provider.dart';
import '../Bloc/noticesBloc.dart';
import '../models/querySnapshot.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';
import '../widgets/contact_user_card.dart';
import 'Message_screen.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}
class _NotificationScreenState extends State<NotificationScreen>  with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List tabs = ["全部", "已认证", "提及"];

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
    return Scaffold(
      backgroundColor:
      width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
        ? null
            : AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title:  const Center(
          child: Text(
            '通知',
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.messenger_outline,
        //       color: primaryColor,
        //     ),
        //     onPressed: () => Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (context) => MessageScreen(),
        //       ),
        //     ),
        //   ),
        // ],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((e) => Tab(text: e)).toList(),
        ),
      ),
      // body: Center(
      //   child: Text('Notification Screen'),
      // ),
      body:TabBarView(
        controller: _tabController,
        children: tabs.map((e) {
          return NoticesList(
            e: e,
            child: Container(
              alignment: Alignment.center,
              child: Text(e, textScaleFactor: 5),
            ),
          );
        }).toList().cast<Widget>(),
      ),
    );
  }
}

class NoticesList extends StatefulWidget {
  final Widget child;
  final String e;
  const NoticesList({Key? key, required this.child, required this.e}) : super(key: key);

  @override
  _NoticesListState createState() => _NoticesListState();
}

class _NoticesListState extends State<NoticesList> with AutomaticKeepAliveClientMixin {
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
    return BlocProvider<NoticesBloc>(
        key: UniqueKey(),//UniqueKey()是一个flutter提供的用于生成唯一key的类，它的原理是通过时间戳来生成key，所以每次生成的key都是不同的，这样就可以保证每次生成的key都是唯一的。
    bloc: bloc,
    child: RefreshIndicator(
      onRefresh: () async {
        bloc?.submitQuery(widget.e);
      },
      child: StreamBuilder(
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
              onPressed: () {
                bloc.createNotice(widget.e, "content");
                // 处理按钮点击事件
              },
              backgroundColor: primaryColor,
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
