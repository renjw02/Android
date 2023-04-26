import 'package:flutter/widgets.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/Auth/customAuth.dart';

//UserProvider的作用是获取当前用户的信息
//这个类是一个ChangeNotifier，当用户信息发生变化时，会通知所有监听了它的组件
//初始化时，会调用CustomAuth().getUserDetails()方法，获取当前用户的信息
class UserProvider with ChangeNotifier {
  late User _user;
  final CustomAuth _authMethods = CustomAuth();

  User get getUser => _user;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}