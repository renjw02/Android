import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/global_variable.dart';
import 'package:frontend/widgets/post_card.dart';

import '../models/DocumentSnapshot.dart';
import '../models/querySnapshot.dart';
DocumentSnapshot trend3 = DocumentSnapshot(
  uid: '1',
  username: 'test',
  likes: [],
  postId: '1',
  datePublished: DateTime.now(),
  description: '114514 114514',
  postUrl: 'https://picsum.photos/200/301',
  profImage: 'https://p0.itc.cn/q_70/images03/20230213/ca107acd0ee943a0ac9e8264a23b6ca4.jpeg',
);

DocumentSnapshot trend2 = DocumentSnapshot(
  uid: '2',
  username: '李永乐老师',
  likes: [],
  postId: '2',
  datePublished: DateTime.now(),
  description: '今天我们来看看这个东西是怎么样的，这....',
  postUrl: 'https://picsum.photos/200/304',
  profImage: 'https://picsum.photos/200/504',
);
DocumentSnapshot trend1 = DocumentSnapshot(
  uid: '3',
  username: '王境泽',
  likes: [],
  postId: '3',
  datePublished: DateTime.now(),
  description: '诶呀，真香',
  postUrl: 'https://picsum.photos/200/305',
  profImage: 'https://picsum.photos/200/505',
);
List<DocumentSnapshot> doc = [trend1, trend2, trend3];

//初始化一个QuerySnapshot对象
QuerySnapshot querySnapshot = QuerySnapshot(docs: doc, readTime: DateTime.now());



class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key, required String postId}) : super(key: key);
  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}
class _CommentsScreenState extends State<CommentsScreen> {
  late Stream<QuerySnapshot> test;
  late StreamController<QuerySnapshot> _streamController;

  @override
  void initState() {
    super.initState();
    test = Stream<QuerySnapshot>.value(querySnapshot);
    _streamController = StreamController<QuerySnapshot>();
    //将test加入到_streamController中
    _streamController.addStream(test);
    // _streamController = CustomStore.instance.collection<QuerySnapshot>("posts");
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: const Text(
            'Comments',
          ),
        ),
        body: StreamBuilder(
          stream: _streamController.stream,
          builder: (context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize ? width * 0.3 : 0,
                  vertical: width > webScreenSize ? 15 : 0,
                ),
                child: PostCard(
                  snap: snapshot.data!.docs[index].data(),
                ),
              ),
            );
          },
        ),
      )
    );
  }
}