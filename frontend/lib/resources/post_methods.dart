import 'dart:typed_data';
import 'database_methods.dart' as db;

class postMethods {

  Future<String> supportPost(int postId, String uid, List supports) async {
    //todo
    print("supportpost");
    print(uid);
    String res = "Fail";
    if(supports.contains(uid)==false){
      res = await db.DataBaseManager().supportPost(postId, 1);
      if(res == "Success"){
        supports.add(uid);
        return "Success";
      }
      else{
        return "Error";
      }
    }
    else{
      res = await db.DataBaseManager().supportPost(postId, -1);
      if(res == "Success"){
        supports.remove(uid);
        return "Fail";
      }
      else{
        return "Error";
      }
    }
  }

  Future<String> starPost(int postId, String uid, String title,List stars) async {
    //todo
    print("starpost");
    print(uid);
    print(stars);
    String res = "Fail";
    if(stars.contains(uid)==false){
      res = await db.DataBaseManager().starPost(postId, uid,title);
      if(res == "Success"){
        stars.add(uid);
        return "Success";
      }
      else{
        return "Error";
      }
    }
    else{
      res = await db.DataBaseManager().cancelStar(postId, uid);
      if(res == "Success"){
        stars.remove(uid);
        return "Success";
      }
      else{
        return "Error";
      }
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

}
