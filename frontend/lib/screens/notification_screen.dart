import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/colors.dart';
import '../utils/global_variable.dart';
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}
class _NotificationScreenState extends State<NotificationScreen> {


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
        title: SvgPicture.asset(
        'assets/logo.svg',
        color: primaryColor,
        height: 32,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.messenger_outline,
              color: primaryColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Text('Notification Screen'),
      ),
    );
  }
}