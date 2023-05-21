import 'package:frontend/Auth/customAuth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/add_post_screen.dart';
import 'package:frontend/screens/feed_screen.dart';
import 'package:frontend/screens/notification_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/search_screen.dart';

const webScreenSize = 600;

const String serverIp = "http://183.172.196.178";
const String serverPort = "5000";
const ip = "$serverIp:$serverPort";
var userLogin = Uri.parse( "$serverIp:$serverPort/api/user/login");
var userRegister = Uri.parse("$serverIp:$serverPort/api/user/register");
var feedsQueryUrl = Uri.parse("$serverIp:$serverPort/api/getpostlist");
var noticeListQueryUrl = Uri.parse("$serverIp:$serverPort/api/notice/getnoticelist");


