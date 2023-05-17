import 'dart:typed_data';

class TextPostMethods {

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    //todo
    String res = "uncompleted";
    return res;
  }

  Future<String> supportPost(String postId, String uid, List supports) async {
    //todo
    print("likepost");
    print(uid);
    if(supports.contains(uid)==false){
      supports.add(uid);
      return "Success";
    }
    else{
      supports.remove(uid);
      return "Fail";
    }
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
