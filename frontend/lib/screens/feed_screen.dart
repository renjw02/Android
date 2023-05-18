import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/Bloc/feedBloc.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/global_variable.dart';
import 'package:frontend/widgets/post_card.dart';

import '../Auth/customAuth.dart';
import '../Bloc/bloc_provider.dart';
import '../models/DocumentSnapshot.dart';
import '../models/querySnapshot.dart';
import '../models/post.dart';
import '../resources/database_methods.dart' as db;
import 'message_screen.dart';
import 'comments_screen.dart';



class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);
  // static Stream<QuerySnapshot> test= Stream<QuerySnapshot>.value(querySnapshot);
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Stream<QuerySnapshot> test;
  late StreamController<QuerySnapshot> _streamController;
  bool isLoading = false;
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
    QuerySnapshot querySnapshot = await db.DataBaseManager().feedsQuery();
    // List<Post> doc = await convertPost(data);
    // QuerySnapshot querySnapshot = QuerySnapshot(docs: doc, readTime: DateTime.now());
    test = Stream<QuerySnapshot>.value(querySnapshot);
    _streamController = StreamController<QuerySnapshot>();
    //将test加入到_streamController中
    _streamController.addStream(test);
    setState(() {
      isLoading = false;
    });
  }

  Future<List<Post>> convertPost(List<dynamic> data) async {
    List<Post> doc = [];
    print(data);
    for(var item in data){
      print(item);
      print(item.runtimeType);
      // Map<String,dynamic>? data;
      // data = await db.DataBaseManager().getThePost(item["id"]);
      // //List<Uint8List> images = data['images'];
      // print(data);
      var asd = Post(
        id:item["id"],
        uid:item["userId"].toString(),
        title:item["title"],
        content:item["content"],
        last_replied_user_id: item["lastRepliedUserId"].toString(),
        last_replied_time:item["lastRepliedTime"],
        created: item["created"],
        updated: item["updated"],
        type: item['type'] ,
        position: "position",  //TODO
        support_num: item["supportNum"],
        comment_num: item["commentNum"],
        star_num: item["starNum"],
        font_size: item["fontSize"],
        font_color:item["fontColor"],
        font_weight: item["fontWeight"],
        supportList: item["supportList"],
        starList: item["starList"],
        images: [],
        videos: [],
      );
      doc.add(asd);
    }
    return doc;
  }

  @override
  void dispose() {
    // _streamController.close();
    // _auth.postStateChanges.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //调试输出
    // debugPrint(querySnapshot.docs[0].data());

    final width = MediaQuery.of(context).size.width;
    final bloc = FeedsBloc();
    // bloc?.selectQuery(querySnapshot);
    bloc.submitQuery();
    return BlocProvider<FeedsBloc>(
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
          title: SvgPicture.asset(
            'assets/logo.svg',
            color: primaryColor,
            height: 32,
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
        ),
        body: StreamBuilder(//StreamBuilder是一个数据包装器，它可以将stream中的数据包装成一个widget，然后将这个widget返回给builder，builder就是一个回调函数，它接收两个参数，第一个参数是context，第二个参数是AsyncSnapshot，AsyncSnapshot是一个泛型，它可以接收任何类型的数据，我们可以通过AsyncSnapshot.data来获取数据。
          // stream: _streamController.stream,//stream是一种数据结构，可以理解为一个队列，数据是一个个的包，每次只能取一个包，取完后就会被删除，然后再取下一个包，以此类推。stream的数据是异步的，也就是说，当我们取完一个包后，不会立即取下一个包，而是要等待一段时间，这段时间就是延迟时间，延迟时间的长短取决于数据包的大小，数据包越大，延迟时间越长。stream的数据是有序的，也就是说，我们取出的数据包是按照顺序取出的，不会出现跳跃的情况。
          // stream: BlocProvider.of<FeedBloc>(context)?.queryStream,
          stream: bloc?.queryStream,
          // stream的数据是不可逆的，也就是说，当我们取出一个数据包后，就会被删除，无法再次取出。
          //  FirebaseFirestore.instance.collection('posts')是一个集合，集合中包含了很多文档，每个文档都是一个数据包，我们可以通过stream取出这些数据包，然后对数据包进行处理。
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
                  snap: snapshot.data?.docs[index].data(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

