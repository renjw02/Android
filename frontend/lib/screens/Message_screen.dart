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
        width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        appBar: width > webScreenSize
            ? null
            : AppBar(
          backgroundColor: mobileBackgroundColor,
          centerTitle: false,
          title: Container(
            margin: EdgeInsets.only(top: 10.0,bottom:5.0),
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
          bottom: TabBar(
            controller: _tabController,
            tabs: tabs.map((e) => Tab(text: e)).toList(),
          ),
        ),
        // body: StreamBuilder(
        //   stream: bloc?.queryStream,
        //   builder: (context,
        //       AsyncSnapshot<QuerySnapshot> snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     }
        //     return ListView.builder(
        //       itemCount: snapshot.data!.docs.length,
        //       itemBuilder: (ctx, index) => Container(
        //         margin: EdgeInsets.symmetric(
        //           horizontal: width > webScreenSize ? width * 0.3 : 0,
        //           vertical: width > webScreenSize ? 15 : 0,
        //         ),
        //         child: ContactUserCard(
        //           snap: snapshot.data?.docs[index].data(),
        //         ),
        //       ),
        //     );
        //   },
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
    );
  }


  @override
  bool get wantKeepAlive => true;
}
