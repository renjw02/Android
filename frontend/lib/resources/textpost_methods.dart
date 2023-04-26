import 'dart:typed_data';

class TextPostMethods {

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    //todo
    String res = "uncompleted";
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    //todo
    String res = "uncompleted";
    return res;
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    //todo
    String res = "uncompleted";
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    //todo
    String res = "uncompleted";
    return res;
  }

  Future<void> followUser(
    String uid,
    String followId
  ) async {
    //todo
  }
}
