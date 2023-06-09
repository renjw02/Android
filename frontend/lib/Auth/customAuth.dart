import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import '../resources/database_methods.dart' as db;
import '../utils/global_variable.dart' as gv;

User fakeUser1 = User(
  username: 'username1',
  uid: 'uid1',
  photoUrl: 'https://picsum.photos/200/311',
  email: 'email1',
  password: 'p',
  nickname: 'bio1',
  jwt:'jwt',
  profile:'profile',
  photo: Uint8List(0),
  followers: [],
  following: [],
  blockList: [],
);
User fakeUser2 = User(
  username: 'username2',
  uid: 'uid2',
  photoUrl: 'https://picsum.photos/200/312',
  email: 'email2',
  password: 'p',
  nickname: 'bio1',
  jwt:'jwt',
  profile:'profile',
  photo: new Uint8List(0),
  followers: [],
  following: [],
  blockList: [],
);
User fakeUser3 = User(
  username: 'username3',
  uid: 'uid3',
  photoUrl: 'https://picsum.photos/200/313',
  email: 'email3',
  password: 'p',
  nickname: 'bio1',
  jwt:'jwt',
  profile:'profile',
  photo: new Uint8List(0),
  followers: [],
  following: [],
  blockList: [],
);
User fakeUser4 = User(
  username: 'username4',
  uid: 'uid4',
  photoUrl: 'https://picsum.photos/200/314',
  email: 'email4',
  password: 'p',
  nickname: 'bio1',
  jwt:'jwt',
  profile:'profile',
  photo: new Uint8List(0),
  followers: [],
  following: [],
  blockList: [],
);
User fakeUser5 = User(
  username: 'username5',
  uid: 'uid5',
  photoUrl: 'https://picsum.photos/200/315',
  email: 'email5',
  password: 'p',
  nickname: 'bio1',
  jwt:'jwt',
  profile:'profile',
  photo: new Uint8List(0),
  followers: [],
  following: [],
  blockList: [],
);
User fakeUser6 = User(
  username: 'username6',
  uid: 'uid6',
  photoUrl: 'https://picsum.photos/200/316',
  email: 'email6',
  password: 'p',
  nickname: 'bio1',
  jwt:'jwt',
  profile:'profile',
  photo: new Uint8List(0),
  followers: [],
  following: [],
  blockList: [],
);
User fakeUser7 = User(
  username: 'username7',
  uid: 'uid7',
  photoUrl: 'https://picsum.photos/200/317',
  email: 'email7',
  password: 'p',
  nickname: 'bio1',
  jwt:'jwt',
  profile:'profile',
  photo: new Uint8List(0),
  followers: [],
  following: [],
  blockList: [],
);
User fakeUser8 = User(
  username: 'username8',
  uid: 'uid8',
  photoUrl: 'https://picsum.photos/200/318',
  email: 'email8',
  password: 'p',
  nickname: 'bio1',
  jwt:'jwt',
  profile:'profile',
  photo: new Uint8List(0),
  followers: [],
  following: [],
  blockList: [],
);
User fakeUser9 = User(
  username: 'username9',
  uid: 'uid9',
  photoUrl: 'https://picsum.photos/200/319',
  email: 'email9',
  password: 'p',
  nickname: 'bio1',
  jwt:'jwt',
  profile:'profile',
  photo: new Uint8List(0),
  followers: [],
  following: [],
  blockList: [],
);


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
  static final storage = const FlutterSecureStorage(webOptions: WebOptions());

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
    profile:'profile',
    photo: Uint8List(0),
    followers: [],
    following: [],
    blockList: [],
  );

  // Implement methods to sign in, sign out and register users
  Future<String> signIn(String email, String password) async {
    // Make a request to your backend with email and password
    // Get the response and parse it as a User object
    // Add the User object to the StreamController
    // Handle errors as needed
    //
    print("asd1");
    String state = await storage.read(key: "loginState") ?? "Fail";
    print(state);
    print("asd2");
    if(state=="Success"){
      var uid = await storage.read(key: "uid");
      var data = {
        'username': await storage.read(key: "username"),
        'uid': uid,
        'jwt':await storage.read(key: "jwt"),
        'photoUrl': await storage.read(key: "photoUrl"),
        'email': await storage.read(key: "email"),
        "password":await storage.read(key: "password"),
        'nickname': await storage.read(key: "nickname"),
        'profile':await storage.read(key: "profile"),
        'followers': [],
        'following': [],
      };
      String? temp = await storage.read(key: "following");
      List<String> following = temp!.split(",");
      String? temp2 = await storage.read(key: "blockList");
      List<String> blockList = temp2!.split(",");
      CustomAuth.currentUser = User(
        username: data['username'] as String,
        password: data['password'] as String,
        uid: data['uid'] as String,
        jwt: data['jwt'] as String,
        photoUrl: data['photoUrl'] as String,
        email: data['email'] as String,
        nickname: data['nickname'] as String,
        profile:data['profile'] as String,
        photo: Uint8List(0),
        followers: data['followers'] as List,
        following: following,
        blockList: blockList,
      );
      Uint8List? _photo = await db.DataBaseManager().getPhoto(uid!);
      CustomAuth.currentUser = User(
        username: data['username'] as String,
        password: data['password'] as String,
        uid: data['uid'] as String,
        jwt: data['jwt'] as String,
        photoUrl: data['photoUrl'] as String,
        email: data['email'] as String,
        nickname: data['nickname'] as String,
        profile:data['profile'] as String,
        photo: _photo!,
        followers: data['followers'] as List,
        following: following,
        blockList: blockList,
      );
      return state;
    }
    print("asd3");
    var url = Uri.parse(gv.ip+"/api/user/login");
    String result;
    result = await db.DataBaseManager().signIn(url, email, password);
    Uint8List? _photo = await db.DataBaseManager().getPhoto(currentUser.uid);
    currentUser = User(
        username: currentUser.username,
        uid: currentUser.uid,
        jwt: currentUser.jwt,
        photoUrl: currentUser.photoUrl,
        photo: _photo,
        email: currentUser.email,
        password: currentUser.password,
        nickname: currentUser.nickname,
        profile: currentUser.profile,
        followers: currentUser.followers,
        following: currentUser.following,
        blockList: currentUser.blockList,
    );
    print("customAuth"+currentUser.jwt);
    print(currentUser.username);
    print(currentUser.uid);
    if(result == "Success"){
      _controller.add(currentUser);
      await storage.write(key: "loginState", value: "Success");
      await storage.write(key: "username", value: currentUser.username);
      await storage.write(key: "uid", value: currentUser.uid);
      await storage.write(key: "jwt", value: currentUser.jwt);
      await storage.write(key: "photoUrl", value: currentUser.photoUrl);
      await storage.write(key: "email", value: currentUser.email);
      await storage.write(key: "password", value: currentUser.password);
      await storage.write(key: "nickname", value: currentUser.nickname);
      await storage.write(key: "profile", value: currentUser.profile);
      String? result = null;
      currentUser.following.forEach((string) =>
      {if (result == null) result = string else result = '$result,$string'});
      await storage.write(key:"following",value: result.toString());
      result = null;
      currentUser.blockList.forEach((string) =>
      {if (result == null) result = string else result = '$result,$string'});
      await storage.write(key:"blockList",value: result.toString());
    }
    return result;
  }

  Future<String> signOut() async {
    // Make a request to your backend to sign out the user
    // Add null to the StreamController to indicate the user is signed out
    // Handle errors as needed
    try {
      var _client = http.Client();
      var url = Uri.parse(gv.ip+"/api/user/logout");
      await _client.post(url,headers: {
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
      },);
      // await _client.post(Uri.parse('https://your-backend.com/signout'));
      await storage.write(key: "loginState", value: "Fail");
      return 'Success';
    } catch (e) {
      // Handle errors as needed
      print(e);
      return 'Failed';
    }
  }

  Future<String> register(String username, String password, String nickname) async {
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
      String result;
      result = await db.DataBaseManager().register(username, password,nickname);
      print(result);
      if(result == "Success"){
        result = await signIn(username, password);
        print(result);
      }
      return result;
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