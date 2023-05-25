import 'package:frontend/Auth/customAuth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/feeds/add_post_screen.dart';
import 'package:frontend/screens/notice/notification_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/search_screen.dart';

const webScreenSize = 600;

const String serverIp = "http://183.172.226.8";
const String serverPort = "5000";
const ip = "$serverIp:$serverPort";
var userLogin = Uri.parse( "$serverIp:$serverPort/api/user/login");
var userRegister = Uri.parse("$serverIp:$serverPort/api/user/register");
var feedsQueryUrl = Uri.parse("$serverIp:$serverPort/api/getpostlist");
var noticeListQueryUrl = Uri.parse("$serverIp:$serverPort/api/notice/getnoticelist");


enum FeedsFilter { all, top, hot, follow, other }

FeedsFilter stringToNewsFilter(String filter) {
  switch (filter) {
    case 'all':
      return FeedsFilter.all;
    case 'top':
      return FeedsFilter.top;
    case 'hot':
      return FeedsFilter.hot;
    case 'follow':
      return FeedsFilter.follow;
    default:
      return FeedsFilter.other;
  }
}
