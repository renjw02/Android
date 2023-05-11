
class AuthMethods {
  signUpUser({required String email, required String password, required String username}) {}
  // to know if there is user logged in or not and then using it in FutureBuilder
  // Future<User> getCurrentUser() async {
  //   User currentUser = FirebaseAuth.instance.currentUser!;
  //   print(currentUser);
  //   return currentUser;
  // }
}