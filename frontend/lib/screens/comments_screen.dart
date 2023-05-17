import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/global_variable.dart';
import 'package:frontend/widgets/post_card.dart';

import '../models/DocumentSnapshot.dart';
import '../models/post.dart';
import '../models/querySnapshot.dart';
Post post1 = Post(
  id: 1,
  uid:"1",
  title:"title1",
  content: "content1",
  last_replied_user_id: "1",
  last_replied_time: "time",
  created:"time",
  updated: "time",
  type:1,
  position: "position",
  support_num: 7,
  comment_num: 7,
  star_num: 7,
  font_size:16,
  font_color: "white",
  font_weight: "适中",
  supportList: ["-1"],
  starList: ["-1"],
  images: [],
  videos: [],
);
Post post2 = Post(
  id: 2,
  uid:"1",
  title:"title2",
  content: "content2",
  last_replied_user_id: "1",
  last_replied_time: "time",
  created:"time",
  updated: "time",
  type:1,
  position: "position",
  support_num: 7,
  comment_num: 7,
  star_num: 7,
  font_size:16,
  font_color: "white",
  font_weight: "适中",
  supportList: ["-1"],
  starList: ["-1"],
  images: [],
  videos: [],
);

List<Post> doc1 = [post1,post2];

//初始化一个QuerySnapshot对象
QuerySnapshot querySnapshot = QuerySnapshot(docs: doc1, readTime: DateTime.now());



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