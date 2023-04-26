import 'package:frontend/Auth/customAuth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/add_post_screen.dart';
import 'package:frontend/screens/feed_screen.dart';
import 'package:frontend/screens/notification_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const NotificationScreen(),
  ProfileScreen(
    uid: CustomAuth.currentUser!.uid,
  ),
];
