import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/global_variable.dart';
import 'package:frontend/widgets/post_card.dart';
class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key, required String postId}) : super(key: key);
  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}
class _CommentsScreenState extends State<CommentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: const Text(
            'Comments',
          ),
        ),
        body: const Center(
          child: Text('Comments Screen'),
        ),
      )
    );
  }
}