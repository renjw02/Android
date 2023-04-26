import 'package:flutter/widgets.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/Auth/customAuth.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final CustomAuth _authMethods = CustomAuth();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}