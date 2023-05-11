import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/user.dart';
import '../resources/database_methods.dart' as db;


// Define a CustomAuth class to communicate with your backend
class CustomAuth {
  // Use http, dio or other packages to make requests to your backend
  // final http.Client _client = http.Client();

  // Use a StreamController to create a Stream<User>
  static final StreamController<User?> _controller = StreamController<User>();

  // Use a singleton pattern to create an instance of CustomAuth
  static final CustomAuth _instance = CustomAuth._();
  factory CustomAuth() => _instance;
  CustomAuth._();

  // Expose the Stream<User> as authStateChanges
  Stream<User?> get authStateChanges => _controller.stream;

  static User currentUser = User(
    username: 'username',
    uid: 'uid',
    jwt: 'jwt',
    photoUrl: 'photoUrl',
    email: 'email',
    password: "password",
    nickname: 'nickname',
    followers: [],
    following: [],
  );

  // Implement methods to sign in, sign out and register users
  Future<String> signIn(String email, String password) async {
    // Make a request to your backend with email and password
    // Get the response and parse it as a User object
    // Add the User object to the StreamController
    // Handle errors as needed
    //
    var url = Uri.parse("http://127.0.0.1:5000/api/user/login");
    String result;
    result = await db.DataBaseManager().signIn(url, email, password);
    if(result == "Success"){
      _controller.add(currentUser);
    }
    return result;



    // final data = {
    //   'username': 'test',
    //   'uid': '1',
    //   'photoUrl': 'photoUrl',
    //   'email': email,
    //   'jwt':'jwt',
    //   'password':password,
    //   'nickname': 'test',
    //   'followers': [],
    //   'following': [],
    // };
    // currentUser = User(
    //   username: data['username'] as String,
    //   uid: data['uid'] as String,
    //   photoUrl: data['photoUrl'] as String,
    //   email: data['email'] as String,
    //   jwt: data['jwt'] as String,
    //   password: data['password'] as String,
    //   nickname: data['nickname'] as String,
    //   followers: data['followers'] as List,
    //   following: data['following'] as List,
    // );
    // _controller.add(currentUser);
    // return 'Success';
  }

  Future<String> signOut() async {
    // Make a request to your backend to sign out the user
    // Add null to the StreamController to indicate the user is signed out
    // Handle errors as needed
    try {
      var _client = http.Client();
      var url = Uri.parse("http://127.0.0.1:5000/api/user/logout");
      await _client.post(url,headers: {
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
      },);
      // await _client.post(Uri.parse('https://your-backend.com/signout'));
      _controller.add(null);
      return 'Success';
    } catch (e) {
      // Handle errors as needed
      print(e);
      return 'Failed';
    }
  }

  Future<String> register(String name, String email, String password) async {
    // Make a request to your backend with name, email and password
    // Get the response and parse it as a User object
    // Add the User object to the StreamController
    // Handle errors as needed
    try {
      // final response = await _client.post(
      //   Uri.parse('https://your-backend.com/register'),
      //   body: {'name': name, 'email': email, 'password': password},
      // );
      // final data = jsonDecode(response.body);

      final data = {
        'username': "username",
        'uid': 'uid',
        'jwt':'jwt',
        'photoUrl': 'photoUrl',
        'email': email,
        "password":password,
        'nickname': 'nickname',
        'followers': [],
        'following': [],
      };
      final user = User(
        username: data['username'] as String,
        password: data['password'] as String,
        uid: data['uid'] as String,
        jwt: data['jwt'] as String,
        photoUrl: data['photoUrl'] as String,
        email: data['email'] as String,
        nickname: data['nickname'] as String,
        followers: data['followers'] as List,
        following: data['following'] as List,
      );
      _controller.add(user);
      return 'Success';
    } catch (e) {
      // Handle errors as needed
      print(e);
      return 'Failed';
    }
  }

  // Dispose the StreamController when not needed
  void dispose() {
    _controller.close();
  }

  getUserDetails() {
    return currentUser;
  }
}