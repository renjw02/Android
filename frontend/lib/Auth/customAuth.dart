import 'dart:async';
import 'dart:convert';

import '../models/user.dart';

User fakeUser1 = User(
  username: 'username1',
  uid: 'uid1',
  photoUrl: 'https://picsum.photos/200/311',
  email: 'email1',
  bio: 'bio1',
  followers: [],
  following: [],
);
User fakeUser2 = User(
  username: 'username2',
  uid: 'uid2',
  photoUrl: 'https://picsum.photos/200/312',
  email: 'email2',
  bio: 'bio2',
  followers: [],
  following: [],
);
User fakeUser3 = User(
  username: 'username3',
  uid: 'uid3',
  photoUrl: 'https://picsum.photos/200/313',
  email: 'email3',
  bio: 'bio3',
  followers: [],
  following: [],
);
User fakeUser4 = User(
  username: 'username4',
  uid: 'uid4',
  photoUrl: 'https://picsum.photos/200/314',
  email: 'email4',
  bio: 'bio4',
  followers: [],
  following: [],
);
User fakeUser5 = User(
  username: 'username5',
  uid: 'uid5',
  photoUrl: 'https://picsum.photos/200/315',
  email: 'email5',
  bio: 'bio5',
  followers: [],
  following: [],
);
User fakeUser6 = User(
  username: 'username6',
  uid: 'uid6',
  photoUrl: 'https://picsum.photos/200/316',
  email: 'email6',
  bio: 'bio6',
  followers: [],
  following: [],
);
User fakeUser7 = User(
  username: 'username7',
  uid: 'uid7',
  photoUrl: 'https://picsum.photos/200/317',
  email: 'email7',
  bio: 'bio7',
  followers: [],
  following: [],
);
User fakeUser8 = User(
  username: 'username8',
  uid: 'uid8',
  photoUrl: 'https://picsum.photos/200/318',
  email: 'email8',
  bio: 'bio8',
  followers: [],
  following: [],
);
User fakeUser9 = User(
  username: 'username9',
  uid: 'uid9',
  photoUrl: 'https://picsum.photos/200/319',
  email: 'email9',
  bio: 'bio9',
  followers: [],
  following: [],
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

  // Expose the Stream<User> as authStateChanges
  Stream<User?> get authStateChanges => _controller.stream;

  static User currentUser = User(
    username: 'username',
    uid: 'uid',
    photoUrl: 'photoUrl',
    email: 'email',
    bio: 'bio',
    followers: [],
    following: [],
  );

  // Implement methods to sign in, sign out and register users
  Future<String> signIn(String email, String password) async {
    // Make a request to your backend with email and password
    // Get the response and parse it as a User object
    // Add the User object to the StreamController
    // Handle errors as needed
    try {
      // final response = await _client.post(
      //   Uri.parse('https://your-backend.com/signin'),
      //   body: {'email': email, 'password': password},
      // );
      // final data = jsonDecode(response.body);
      final data = {
        'username': 'username',
        'uid': 'uid',
        'photoUrl': 'photoUrl',
        'email': 'email',
        'bio': 'bio',
        'followers': [],
        'following': [],
      };
      currentUser = User(
        username: data['username'] as String,
        uid: data['uid'] as String,
        photoUrl: data['photoUrl'] as String,
        email: data['email'] as String,
        bio: data['bio'] as String,
        followers: data['followers'] as List,
        following: data['following'] as List,
      );
      _controller.add(currentUser);
      return 'Success';
    } catch (e) {
      // Handle errors as needed
      print(e);
      return 'Failed';
    }
  }

  Future<String> signOut() async {
    // Make a request to your backend to sign out the user
    // Add null to the StreamController to indicate the user is signed out
    // Handle errors as needed
    try {
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
        'username': 'username',
        'uid': 'uid',
        'photoUrl': 'photoUrl',
        'email': 'email',
        'bio': 'bio',
        'followers': [],
        'following': [],
      };
      final user = User(
        username: data['username'] as String,
        uid: data['uid'] as String,
        photoUrl: data['photoUrl'] as String,
        email: data['email'] as String,
        bio: data['bio'] as String,
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