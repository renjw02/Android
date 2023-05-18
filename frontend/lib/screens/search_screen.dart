import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frontend/Auth/customAuth.dart';
import 'package:frontend/screens/profile_screen.dart';

import '../models/DocumentSnapshot.dart';
import '../models/querySnapshot.dart';
import '../models/user.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';

DocumentSnapshot trend1 = DocumentSnapshot(
  uid: '1',
  username: 'username1',
  likes: [],
  postId: '1',
  datePublished: DateTime.now(),
  description: 'description1',
  postUrl: 'https://picsum.photos/200/300',
  profImage: 'https://picsum.photos/200/500',
);

DocumentSnapshot trend2 = DocumentSnapshot(
  uid: '2',
  username: 'username2',
  likes: [],
  postId: '2',
  datePublished: DateTime.now(),
  description: 'description2',
  postUrl: 'https://picsum.photos/200/302',
  profImage: 'https://picsum.photos/200/502',
);
DocumentSnapshot trend3 = DocumentSnapshot(
  uid: '3',
  username: 'username3',
  likes: [],
  postId: '3',
  datePublished: DateTime.now(),
  description: 'description3',
  postUrl: 'https://picsum.photos/200/303',
  profImage: 'https://picsum.photos/200/503',
);
DocumentSnapshot trend4 = DocumentSnapshot(
  uid: '4',
  username: 'username4',
  likes: [],
  postId: '4',
  datePublished: DateTime.now(),
  description: 'description4',
  postUrl: 'https://picsum.photos/200/304',
  profImage: 'https://picsum.photos/200/504',
);
DocumentSnapshot trend5 = DocumentSnapshot(
  uid: '5',
  username: 'username5',
  likes: [],
  postId: '5',
  datePublished: DateTime.now(),
  description: 'description5',
  postUrl: 'https://picsum.photos/200/305',
  profImage: 'https://picsum.photos/200/505',
);
DocumentSnapshot trend6 = DocumentSnapshot(
  uid: '6',
  username: 'username6',
  likes: [],
  postId: '6',
  datePublished: DateTime.now(),
  description: 'description6',
  postUrl: 'https://picsum.photos/200/306',
  profImage: 'https://picsum.photos/200/506',
);
DocumentSnapshot trend7 = DocumentSnapshot(
  uid: '7',
  username: 'username7',
  likes: [],
  postId: '7',
  datePublished: DateTime.now(),
  description: 'description7',
  postUrl: 'https://picsum.photos/200/307',
  profImage: 'https://picsum.photos/200/507',
);
DocumentSnapshot trend8 = DocumentSnapshot(
  uid: '8',
  username: 'username8',
  likes: [],
  postId: '8',
  datePublished: DateTime.now(),
  description: 'description8',
  postUrl: 'https://picsum.photos/200/308',
  profImage: 'https://picsum.photos/200/508',
);
DocumentSnapshot trend9 = DocumentSnapshot(
  uid: '9',
  username: 'username9',
  likes: [],
  postId: '9',
  datePublished: DateTime.now(),
  description: 'description9',
  postUrl: 'https://picsum.photos/200/309',
  profImage: 'https://picsum.photos/200/509',
);
DocumentSnapshot trend10 = DocumentSnapshot(
  uid: '10',
  username: 'username10',
  likes: [],
  postId: '10',
  datePublished: DateTime.now(),
  description: 'description10',
  postUrl: 'https://picsum.photos/200/310',
  profImage: 'https://picsum.photos/200/510',
);
DocumentSnapshot trend11 = DocumentSnapshot(
  uid: '11',
  username: 'username11',
  likes: [],
  postId: '11',
  datePublished: DateTime.now(),
  description: 'description11',
  postUrl: 'https://picsum.photos/200/311',
  profImage: 'https://picsum.photos/200/511',
);
DocumentSnapshot trend12 = DocumentSnapshot(
  uid: '12',
  username: 'username12',
  likes: [],
  postId: '12',
  datePublished: DateTime.now(),
  description: 'description12',
  postUrl: 'https://picsum.photos/200/312',
  profImage: 'https://picsum.photos/200/512',
);

List<DocumentSnapshot> doc = [trend1, trend2, trend3, trend4, trend5, trend6, trend7, trend8, trend9, trend10, trend11, trend12];

//初始化一个QuerySnapshot对象
QuerySnapshot querySnapshot = QuerySnapshot(docs: doc, readTime: DateTime.now());
List<User> UserDoc = [fakeUser1, fakeUser2, fakeUser3, fakeUser4, fakeUser5, fakeUser6, fakeUser7, fakeUser8, fakeUser9];
QuerySnapshot UserSnapshot = QuerySnapshot(docs: UserDoc, readTime: DateTime.now());

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> {
  //searchController的作用是用来获取用户输入的内容
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  final Future<dynamic> _futureValue = Future.delayed(const Duration(seconds: 1), () => UserSnapshot);
  Future<dynamic> fakeFuture = Future.delayed(const Duration(seconds: 1) , () => querySnapshot);
  @override
  void initState() {
    super.initState();

    // _streamController = CustomStore.instance.collection<QuerySnapshot>("posts");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          // title: Form(
          //   child: TextFormField(
          //     controller: searchController,
          //     decoration:
          //     const InputDecoration(labelText: 'Search for a user...'),
          //     onFieldSubmitted: (String _) {
          //       setState(() {
          //         isShowUsers = true;
          //       });
          //       print(_);
          //     },
          //   ),
          // ),
          title: Container(
            margin: EdgeInsets.all(10.0),
            height: 35.0,
            child: Form(
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search for a user...',
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
        ),
      body: isShowUsers
          ? FutureBuilder(
        // future: FirebaseFirestore.instance
        //     .collection('users')
        //     .where(
        //       'username',
        //       isGreaterThanOrEqualTo: searchController.text,
        //     )
        //     .get(),
        future: _futureValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      uid: (snapshot.data! as dynamic).docs[index].data()['uid'],
                    ),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      (snapshot.data! as dynamic).docs[index].data()['photoUrl'],
                    ),
                    radius: 16,
                  ),
                  title: Text(
                    (snapshot.data! as dynamic).docs[index].data()['username'],
                  ),
                ),
              );
            },
          );
        },
      )
          : FutureBuilder(
        // future: FirebaseFirestore.instance
        //     .collection('posts')
        //     .orderBy('datePublished')
        //     .get(),
        future: fakeFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return StaggeredGridView.countBuilder(
            crossAxisCount: 3,
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) => Image.network(
              (snapshot.data! as dynamic).docs[index].data()['postUrl'].toString(),
              fit: BoxFit.cover,
            ),
            staggeredTileBuilder: (index) => MediaQuery.of(context)
                .size
                .width >
                webScreenSize
                ? StaggeredTile.count(
                (index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
                : StaggeredTile.count(
                (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          );
        },
      ),
    );
  }
}