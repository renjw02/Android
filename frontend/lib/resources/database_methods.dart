//   TODO
import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:frontend/Auth/customAuth.dart';
import 'package:frontend/models/post.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/message.dart';
import '../models/notice.dart';
import '../models/comment.dart';
import '../models/querySnapshot.dart';
import '../models/user.dart';
import '../utils/global_variable.dart'as gv;
import '../utils/global_variable.dart';

class DataBaseManager{
  final http.Client _client = http.Client();
  // 登陆
  Future<dynamic> signIn(Uri url,String email,String password) async {
    Map<String, String> headersMap = new Map();
    headersMap["content-type"] = ContentType.json.toString();
    Map<String, String> bodyParams = new Map();
    bodyParams["username"] = email;
    bodyParams["password"] = password;
    var result="Fail";
    try{
      await _client.post(
          url,
          headers:headersMap,
          // body: bodyParams,
          body:jsonEncode({
            "username":email,
            "password":password,
          }),
          encoding: Utf8Codec()
      ).then((http.Response response) async {
        if (response.statusCode == 200) {
          Map<String, dynamic> returndata = jsonDecode(response.body);
          print(returndata);
          final data = {
            'username': returndata['username'],
            'uid': returndata['userId'].toString(),
            'jwt':returndata['jwt'],
            'photoUrl': 'photoUrl',
            'email': email,
            "password":password,
            'nickname': returndata['nickname'],
            'profile':returndata['profile'],
            'followers': [],
            'following': [],
          };
          CustomAuth.currentUser = User(
            username: data['username'] as String,
            password: data['password'] as String,
            uid: data['uid'] as String,
            jwt: data['jwt'] as String,
            photoUrl: data['photoUrl'] as String,
            photo: Uint8List(0),
            email: data['email'] as String,
            nickname: data['nickname'] as String,
            profile:data['profile'] as String,
            followers: data['followers'] as List,
            following: data['following'] as List,
            blockList: [],
          );
          url = Uri.parse(gv.ip+"/api/user/getfollowedlist/"+data['uid'] as String);
          Map<String,dynamic> tempfollowing = await getSomeMap(url);
          List<String> following = [];
          for(var item in tempfollowing['followedList']){
            following.add(item['followedUserId'].toString());
          }
          url = Uri.parse(gv.ip+"/api/user/getblockedlist/"+data['uid'] as String);
          Map<String,dynamic> tempblock = await getSomeMap(url);
          List<String> blockList = [];
          for(var item in tempblock['blockedList']){
            blockList.add(item['blockedUserId'].toString());
          }
          CustomAuth.currentUser = User(
            username: data['username'] as String,
            password: data['password'] as String,
            uid: data['uid'] as String,
            jwt: data['jwt'] as String,
            photoUrl: data['photoUrl'] as String,
            photo: Uint8List(0),
            email: data['email'] as String,
            nickname: data['nickname'] as String,
            profile:data['profile'] as String,
            followers: data['followers'] as List,
            following: following,
            blockList: blockList,
          );
          result = "Success";
        } else {
          print('error code');
        }
      }).catchError((error) {
        print(error);
        print('error 11');
      });
    }catch(e){
      print('second False');
    }
    return result;
  }
  //  使用ID获取指定user
  Future<Map<String, dynamic>> getSomeMap(Uri url) async{
    Map<String, dynamic> info = {};
    print("getSomeMap");
    await _client.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
      },
    ).then((http.Response response) {
      //处理响应信息
      if (response.statusCode == 200) {
        info = jsonDecode(response.body);
      } else {
        print('error');
        print(response.body);
      }
    }).catchError((e){
      print(e);
    });
    return info;
  }
  
  Future<String> changeInfo(String username,String nickname,String profile,String password,)async {
    Uri url = Uri.parse(gv.ip+"/api/user/changeattr");
    print(username);
    print(profile);
    print(password);
    String res = "Fail";
    await _client.post(
      url,
      headers:{
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
        "content-type": ContentType.json.toString(),
      },
      // body: bodyParams,
      body:jsonEncode({
        "username":username,
        "nickname":nickname,
        "profile":profile,
      }),
    ).then((http.Response response){
      print(response.statusCode);
      print(jsonDecode(response.body)['message']);
      if(response.statusCode == 200){
        if(password == CustomAuth.currentUser.password){
          CustomAuth.currentUser = User(
          username: username,
          uid: CustomAuth.currentUser.uid,
          jwt: CustomAuth.currentUser.jwt,
          photoUrl: CustomAuth.currentUser.photoUrl,
          photo: CustomAuth.currentUser.photo,
          email: CustomAuth.currentUser.email,
          password: password,
          nickname: nickname,
          profile: profile,
          followers: CustomAuth.currentUser.followers,
          following: CustomAuth.currentUser.following,
          blockList: CustomAuth.currentUser.blockList);
          res = "Success";
        }
      }
    });
    if(password != CustomAuth.currentUser.password){
      url = Uri.parse(gv.ip+"/api/user/resetpw");
      await _client.post(
        url,
        headers:{
          HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
          "content-type": ContentType.json.toString(),
        },
        // body: bodyParams,
        body:jsonEncode({
          "username":username,
          "password":password,
        }),
      ).then((http.Response response){
        print(jsonDecode(response.body)['message']);
        if(response.statusCode==200) {
          CustomAuth.currentUser = User(
            username: username,
            uid: CustomAuth.currentUser.uid,
            jwt: CustomAuth.currentUser.jwt,
            photoUrl: CustomAuth.currentUser.photoUrl,
            photo: CustomAuth.currentUser.photo,
            email: CustomAuth.currentUser.email,
            password: password,
            nickname: nickname,
            profile: profile,
            followers: CustomAuth.currentUser.followers,
            following: CustomAuth.currentUser.following,
            blockList: CustomAuth.currentUser.blockList,
          );
          res = "Success";
        }
        else{
        }
      });
    }
    return res;
  }

  Future<String> uploadPhoto(Uint8List file) async {
    String res="Success";
    try{
      FormData fd = FormData.fromMap({
        "file":MultipartFile.fromBytes(file,filename:'asd.jpg',contentType: new MediaType("image", "jpeg")),
      });
      var dio = new Dio();
      dio.options.headers['Content-Type']='multipart/form-data';
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      var response = await dio.post(gv.ip+"/api/user/uploadavatar",data:fd,);
      if (response.statusCode == 200) {
        res = "Success";
      }
      else{
        res = "Fail";
      }
    }catch (exception) {
      print("文件上传失败");
      res = "Fail";
    }
    return res;
  }

  Future<Uint8List> getPhoto(String uid) async {
    try{
      var dio = new Dio();
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      print("getphoto"+CustomAuth.currentUser.jwt);
      Map<String,dynamic> paras = {"name":uid+".jpg"};
      print(paras);
      var response = await dio.get(gv.ip+"/api/user/downloadavatar",queryParameters: paras,
        options: Options(responseType: ResponseType.stream),);
      final stream = await (response.data as ResponseBody).stream.toList();
      if (response.statusCode == 200) {
        final result = BytesBuilder();
        for (Uint8List subList in stream) {
          result.add(subList);
        }
        return result.takeBytes();
      }
      else{
        paras = {"name":"shushu.jpg"};
        var response = await dio.get(gv.ip+"/api/user/downloadavatar",queryParameters: paras,
          options: Options(responseType: ResponseType.stream),);
        final stream = await (response.data as ResponseBody).stream.toList();
        final result = BytesBuilder();
        for (Uint8List subList in stream) {
          result.add(subList);
        }
        return result.takeBytes();
      }
    }catch (exception) {
      print("文件下载失败");
      var dio = new Dio();
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      Map<String,dynamic> paras;
      paras = {"name":"shushu.jpg"};
      var response = await dio.get(gv.ip+"/api/user/downloadavatar",queryParameters: paras,
        options: Options(responseType: ResponseType.stream),);
      final stream = await (response.data as ResponseBody).stream.toList();
      final result = BytesBuilder();
      for (Uint8List subList in stream) {
        result.add(subList);
      }
      return result.takeBytes();
    }
  }

  Future<void> followUser(String uid) async {
    Uri url = Uri.parse(gv.ip+"/api/user/followuser/"+uid);
    await _client.post(
      url,
      headers:{
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
        "content-type": ContentType.json.toString(),
      },
    ).then((http.Response response){
      print(jsonDecode(response.body));
      if(CustomAuth.currentUser.following.indexOf(uid) == -1){
        CustomAuth.currentUser.following.add(uid);
        print(CustomAuth.currentUser.following);
      }
      print(jsonDecode(response.body)['message']);
    });
  }

  Future<void> unFollowUser(String uid) async {
    Uri url = Uri.parse(gv.ip+"/api/user/cancelfollow/"+uid);
    await _client.post(
      url,
      headers:{
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
        "content-type": ContentType.json.toString(),
      },
    ).then((http.Response response){
      print(jsonDecode(response.body));
      if(CustomAuth.currentUser.following.indexOf(uid) != -1){
        CustomAuth.currentUser.following.remove(uid);
        print(CustomAuth.currentUser.following);
      }
      print(jsonDecode(response.body)['message']);
    });
  }
  Future<void> blockUser(String uid) async {
    Uri url = Uri.parse(gv.ip+"/api/user/blockuser/"+uid);
    await _client.post(
      url,
      headers:{
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
        "content-type": ContentType.json.toString(),
      },
    ).then((http.Response response){
      print(jsonDecode(response.body));
      if(CustomAuth.currentUser.blockList.indexOf(uid) == -1){
        CustomAuth.currentUser.blockList.add(uid);
        print(CustomAuth.currentUser.blockList);
      }
      print(jsonDecode(response.body)['message']);
    });
  }
  Future<void> unBlockUser(String uid) async {
    Uri url = Uri.parse(gv.ip+"/api/user/cancelblock/"+uid);
    await _client.post(
      url,
      headers:{
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
        "content-type": ContentType.json.toString(),
      },
    ).then((http.Response response){
      print(jsonDecode(response.body));
      if(CustomAuth.currentUser.blockList.indexOf(uid) != -1){
        CustomAuth.currentUser.blockList.remove(uid);
        print(CustomAuth.currentUser.blockList);
      }
      print(jsonDecode(response.body)['message']);
    });
  }

  Future<String> createPost(String title,String content,int type,String position,int font_size,String font_color,
  String font_weight,List<Uint8List?> files,List<int?> fileTypes) async {
    String res = "动态上传失败";
    try{
      List<MultipartFile> mfiles=[];
      int count=0;
      for(Uint8List? file in files){
        if(file != null){
          if(fileTypes[count]==0){
            mfiles.add(MultipartFile.fromBytes(file,filename:'${title}${count}.jpg',contentType: new MediaType("image", "jpeg")));
          }
          else{
            mfiles.add(MultipartFile.fromBytes(file,filename:'${title}${count}.mp4',contentType: new MediaType("video", "mp4")));
          }
          count++;
        }
      }
      FormData fd = FormData.fromMap({
        "title":title,
        "content":content,
        "type":type,
        "position":position,
        "font_size":font_size,
        "font_color":font_color,
        "font_weight":font_weight,
        "file":mfiles,
      });
      print("asd");
      var dio = new Dio();
      dio.options.headers['Content-Type']='multipart/form-data';
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      print("asd1");
      var response = await dio.post(gv.ip+"/api/post/createpost",data:fd,);
      print("asd2");
      print(response.data);
      print(response.data.runtimeType);
      var m = Map.from(response.data);
      print(m);
      print(m.runtimeType);
      if (response.statusCode == 200) {
        res = "动态上传成功";
      }
      else{
        print("动态上传状态码错误");
      }
    }catch (exception) {
      print("动态上传exception");
    }
    return res;
  }

  List<Post> convertPost(List<dynamic> data){
    List<Post> doc = [];
    print("convertPost");
    for(var item in data){
      doc.add(
          Post(
            id:item["id"],
            userId:item["userId"].toString(),
            title:item["title"],
            nickname: item["nickname"],
            comments: item["comments"] == [] as List<Comment> ? [] : item["comments"] as List<Comment>,
            content:item["content"],
            last_replied_user_id: item["lastRepliedUserId"].toString(),
            last_replied_time:item["lastRepliedTime"],
            created: item["created"],
            updated: item["updated"],
            type: item['type'] ,
            position: "position",  //TODO
            support_num: item["supportNum"],
            comment_num: item["commentNum"],
            star_num: item["starNum"],
            font_size: item["fontSize"],
            font_color:item["fontColor"],
            font_weight: item["fontWeight"],
            supportList: item["supportList"],
            starList: item["starList"],
            images: [],
            videos: [],
          )
      );
    }
    return doc;
  }
  //getPost
  Future<QuerySnapshot>  feedsQuery([int page=1,int size=10,int userId=0,String? orderByWhat=null,int type=0,bool? onlyFollowing=null,
    bool? hot=null]) async {
    QuerySnapshot querySnapshot = QuerySnapshot(
      docs: [], readTime: DateTime.now(),
    );
    try{
      var dio = new Dio();
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      Map<String,dynamic> paras = {
        "page":page,
        "size":size,
        "userId":userId,
        "type":type,
      };
      if(orderByWhat != null){
        paras["orderByWhat"] = orderByWhat;
      }
      if(onlyFollowing != null){
        paras["onlyFollowing"] = onlyFollowing;
      }
      if(hot != null){
        paras["hot"] = hot;
      }
      var response = await dio.get(gv.ip+"/api/post/getpostlist",queryParameters: paras);
      var m = Map.from(response.data);
      if (response.statusCode == 200) {
        // return m['posts'];
        querySnapshot = QuerySnapshot(
          docs: convertPost(m['posts']), readTime: DateTime.now(),
        );
        print("获取动态成功");
        return querySnapshot;
      }
      else{
        print("获取动态失败");
        return querySnapshot;
      }
    }catch (exception) {
      print(exception);
      print("获取动态错误");
      return querySnapshot;
    }
  }

  Future<List<List<int>>> getNewPostList([int page=1,int size=10,int userId=0, String? orderByWhat=null,int type=0, bool? onlyFollowing=null,
    bool? hot=null]) async{
    List<int> newFeedIdList =[];
    List<int> feedCreatorIdList =[];
    try{
      var dio = new Dio();
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      Map<String,dynamic> paras = {
        "page":page,
        "size":size,
        "userId":userId,
        "type":type,
      };
      if(orderByWhat != null){
        paras["orderByWhat"] = orderByWhat;
      }
      if(onlyFollowing != null){
        paras["onlyFollowing"] = onlyFollowing;
      }
      if(hot != null){
        paras["hot"] = hot;
      }
      var response = await dio.get(gv.ip+"/api/post/getpostlist",queryParameters: paras);
      var m = Map.from(response.data);
      if (response.statusCode == 200) {
        // return m['posts'];
        // querySnapshot = QuerySnapshot(
        //   docs: convertPost(m['posts']), readTime: DateTime.now(),
        // );
        for(var item in m['posts']){
          newFeedIdList.add(item['id']);
          feedCreatorIdList.add(item['userId']);
        }
        print("获取动态成功");
      }
      else{
        print("获取动态失败");
      }
    }catch (exception) {
      print(exception);
      print("获取动态错误");
    }
    return [newFeedIdList,feedCreatorIdList];
  }

  Future<String> createNotice([int type=0,String? content = null,int noticeCreator= 1,int userId = 1]) async{
    //把string的数字转成int
    int uid = int.parse(CustomAuth.currentUser.uid);
    content = content ?? "关注了你";

    var result="Fail";
    try{
      var url = Uri.parse("$serverIp:$serverPort/api/notice/createnotice");
      Map<String, String> headersMap = new Map();
      headersMap["content-type"] = ContentType.json.toString();
      var jsonBody = jsonEncode({
        "content": content,
        "user_id":uid,
        "type":type as int,
      });
      if(type >= 1){
        jsonBody = jsonEncode({
          "content": content,
          "user_id": userId,
          "type":type as int,
          "creator_id":noticeCreator,
        });
      }
      await _client.post(
          url,
          // headers:headersMap,
          headers:{
            HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
            "content-type": ContentType.json.toString(),
          },
          // body: bodyParams,
          // body:jsonEncode({
          //   "content": content,
          //   "user_id":uid,
          //   "type":type as int,
          // }),
          body:jsonBody,
          encoding: Utf8Codec()
      ).then((http.Response response){
        if (response.statusCode == 200){
          Map<String, dynamic> returnData = jsonDecode(response.body);
          print(returnData);
          if(returnData['message']=="ok"){
            result="Success";
          }else{
            print(returnData['message']);
          }
          result ="Success";
        }else{
          print("error code:");
          print(response.statusCode);
          print(response.body);
        }
      }).catchError((error) {
        print("catchError:");
        print(error);
      });

    }catch (exception) {
      print(exception);
      print("创建noticeList错误");
    }
    return result;
  }

  Future<String> removeNotice(int noticeId) async{
    //把string的数字转成int
    String result="Fail";
    try{
      String uid = CustomAuth.currentUser.uid.toString();
      var url = Uri.parse("$serverIp:$serverPort/api/notice/removenotice/$noticeId");
      await _client.post(
        url,
        headers:{
          HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
          "content-type": ContentType.json.toString(),
        },
      ).then((http.Response response){
        print(jsonDecode(response.body));
        if (response.statusCode == 200){
          Map<String, dynamic> returnData = jsonDecode(response.body);
          print(returnData);
          if(returnData['message']=="ok"){
            result="Success";
          }else{
            print(returnData['message']);
          }
        }
      }).catchError((error) {
        print("catchError:");
        print(error);
      });
    } catch (exception) {
      print(exception);
      print("删除noticeList错误");
    }
    return result;
  }

  Future<QuerySnapshot> noticeListQuery() async{
    QuerySnapshot querySnapshot = QuerySnapshot(
      docs: [], readTime: DateTime.now(),
    );
    try{
      String uid = CustomAuth.currentUser.uid.toString();
      var url = Uri.parse("$serverIp:$serverPort/api/notice/getnoticelist/$uid");
      await _client.get(
        url,
        headers:{
          HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
          "content-type": ContentType.json.toString(),
        },
      ).then((http.Response response){
        print(jsonDecode(response.body));
        if (response.statusCode == 200){
          Map<String, dynamic> returnData = jsonDecode(response.body);
          print(returnData);
          if(returnData['message']=="ok"){
            querySnapshot = QuerySnapshot(
              docs: Notice.fromJsonList(returnData['noticeList']), readTime: DateTime.now(),
            );
          }else{
            print(returnData['message']);
          }
        }
      }).catchError((error) {
        print("catchError:");
        print(error);
      });
    } catch (exception) {
      print(exception);
      print("获取noticeList错误");
    }
    return querySnapshot;
  }

  // 获取私信内容
  Future<String> noticeContentQuery(int noticeId) async {
    String content = "";
    print("noticeContentQuery");
    try {
      var url = Uri.parse("$serverIp:$serverPort/api/notice/getnotice/$noticeId");
      await _client.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
          "content-type": ContentType.json.toString(),
        },
      ).then((http.Response response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> returnData = jsonDecode(response.body);
          if (returnData['message'] == "ok") {
            print("content:");
            print(returnData['content']);
            content = returnData['content'] ?? "";
          } else {
            print(returnData['message']);
          }
        }
      }).catchError((error) {
        print("catchError:");
        print(error);
      });
    } catch (exception) {
      print(exception);
      print("获取私信内容错误");
    }

    return content;
  }

  // 获取未读私信数量
  Future<int> unreadNoticeCountQuery() async {
    int count = 0;

    try {
      String uid = CustomAuth.currentUser.uid.toString();
      var url = Uri.parse("$serverIp:$serverPort/api/notice/getunreadnum/$uid");
      await _client.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
          "content-type": ContentType.json.toString(),
        },
      ).then((http.Response response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> returnData = jsonDecode(response.body);
          if (returnData['message'] == "ok") {
            count = returnData['data'] ?? 0;
          } else {
            print(returnData['message']);
          }
        }
      }).catchError((error) {
        print("catchError:");
        print(error);
      });
    } catch (exception) {
      print(exception);
      print("获取未读私信数量错误");
    }

    return count;
  }

  Future<Map<String,dynamic>?> getThePost(int id) async{
    try{
      var dio = new Dio();
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      var response = await dio.get(gv.ip+"/api/post/getpost/"+id.toString());
      if (response.statusCode == 200) {
        // result['images'] = m['images'];
        // result['videos'] = m['videos'];
        print("获取动态成功");
        print(response.data['post']);
        return response.data['post'];
      }
      else{
        print("获取动态失败");
        return null;
      }
    }catch (exception) {
      print(exception);
      print("获取动态错误");
      return null;
    }
  }

  Future<String> register(String username, String password, String nickname) async {
    var url = Uri.parse(gv.ip+"/api/user/register");
    Map<String, String> headersMap = new Map();
    headersMap["content-type"] = ContentType.json.toString();
    var result="Fail";
    try{
      await _client.post(
          url,
          headers:headersMap,
          // body: bodyParams,
          body:jsonEncode({
            "nickname":nickname,
            "username":username,
            "password":password,
          }),
          encoding: Utf8Codec()
      ).then((http.Response response){
        if (response.statusCode == 200){
          Map<String, dynamic> returnData = jsonDecode(response.body);
          print(returnData);
          if(returnData['message']=="ok"){
            result="Success";
          }else{
            print(returnData['message']);
          }
        }else{
          print("error code:");
          print(response.statusCode);
        }
      }).catchError((error) {
        print("catchError:");
        print(error);
      });
    }catch(e){
      print("catch(e):");
      print(e);
    }
    return result;
  }

  Future<String> createMessage(int senderId, int receiverId, String content) async {
    String result = "";
    try {
      var url = Uri.parse("$serverIp:$serverPort/api/message/createmessage");
      await _client.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
          "content-type": ContentType.json.toString(),
        },
        body: jsonEncode({
          "sender_id": senderId,
          "receiver_id": receiverId,
          "content": content,
        }),
      ).then((http.Response response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> returnData = jsonDecode(response.body);
          if (returnData['message'] == "ok") {
            result = returnData['messageId'].toString();
          } else {
            print(returnData['message']);
          }
        }
      }).catchError((error) {
        print("catchError:");
        print(error);
      });
    } catch (exception) {
      print(exception);
      print("创建私信错误");
    }
    return result;
  }

  Future<QuerySnapshot> getChatHistory(int senderId, int receiverId) async {
    QuerySnapshot querySnapshot = QuerySnapshot(
      docs: [], readTime: DateTime.now(),
    );
    try {
      var url = Uri.parse("$serverIp:$serverPort/api/message/gethistory/$senderId/$receiverId");
      await _client.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
          "content-type": ContentType.json.toString(),
        },
      ).then((http.Response response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> returnData = jsonDecode(response.body);
          if (returnData['message'] == "ok") {
            List<dynamic> historyList = returnData['history'];
            print("historyList:");
            print(historyList);
            querySnapshot = QuerySnapshot(
              docs: Message.fromJsonList(historyList), readTime: DateTime.now(),
            );
          } else {
            print(returnData['message']);
          }
        }
      }).catchError((error) {
        print("catchError:");
        print(error);
      });
    } catch (exception) {
      print(exception);
      print("获取历史对话错误");
    }
    return querySnapshot;
  }

  Future<Map<String, dynamic>?> getMessageContent(int messageId) async {
    Map<String, dynamic>? messageContent;
    try {
      var url = Uri.parse("$serverIp:$serverPort/api/message/getmessage/$messageId");
      await _client.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
          "content-type": ContentType.json.toString(),
        },
      ).then((http.Response response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> returnData = jsonDecode(response.body);
          if (returnData['message'] == "ok") {
            messageContent = {
              "messageId": returnData['messageId'].toString(),
              "content": returnData['content'],
              "type": returnData['type'],
              "creator": returnData['creator'],
              "created": returnData['created'],
            };
          } else {
            print(returnData['message']);
          }
        }
      }).catchError((error) {
        print("catchError:");
        print(error);
      });
    } catch (exception) {
      print(exception);
      print("获取私信内容错误");
    }
    return messageContent;
  }

  Future<QuerySnapshot> messageListQuery() async {
    QuerySnapshot querySnapshot = QuerySnapshot(
      docs: [], readTime: DateTime.now(),
    );
    try{
      var url = Uri.parse("$serverIp:$serverPort/api/message/messagelist");
      await _client.get(
        url,
        headers:{
          HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
          "content-type": ContentType.json.toString(),
        },
      ).then((http.Response response){
        if (response.statusCode == 200){
          Map<String, dynamic> returnData = jsonDecode(response.body);
          if(returnData['message']=="ok"){
            querySnapshot = QuerySnapshot(
              docs: Message.fromJsonList(returnData['messageList']), readTime: DateTime.now(),
            );
          }else{
            print(returnData['message']);
          }
        }
      }).catchError((error) {
        print("catchError:");
        print(error);
      });
    } catch (exception) {
      print(exception);
      print("获取私信列表错误");
    }
    return querySnapshot;
  }

  Future<List<String>?> getImageUrls(id) async {
    try{
      var dio = new Dio();
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      var response = await dio.get(gv.ip+"/api/post/getpictureslist/"+id.toString());
      print("getImageUrls asd1");
      print(response.data);
      print("response.statusCode:");
      print(response.statusCode);
      Map<String,dynamic> result = {};
      if (response.statusCode == 200) {
         //将response.data转换成List<string>
        List<String> imageUrls = [];
        for (var i = 0; i < response.data.length; i++) {
          imageUrls.add(response.data[i]);
        }
        //将每个url前面加上ip,port
        imageUrls = imageUrls.map((e) => gv.ip+"/api/media/photo?name=" +e).toList();
        print("imageUrls:");
        print(imageUrls);
        return imageUrls;
      }
      else{
        print("获取动态失败");
        return null;
      }
    }catch (exception) {
      print(exception);
      print("获取动态错误");
      return null;
    }
  }

  Future<String> supportPost(int postid,int type) async {
    String res = "Fail";
    try{
      var dio = new Dio();
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      var response = await dio.post(gv.ip+"/api/post/supportpost/$postid",data: {"type":type,});
      print("supportpost asd1");
      var m = Map.from(response.data);
      //print(m);
      print(m);
      print(m.runtimeType);
      print(response.statusCode);
      if (response.statusCode == 200) {
        res = "Success";
      }
      else{
        print("点赞或取消点赞失败");
      }
    }catch (exception) {
      print(exception);
      print("点赞或取消点赞失败");
    }
    return res;
  }

  Future<String> starPost(int postid,String uid,String title) async {
    String res = "Fail";
    try{
      var dio = new Dio();
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      var response = await dio.post(gv.ip+"/api/star/collectpost",data: {
        "post_id":postid,
        "user_id":int.parse(uid),
        "title":title,
      });
      print("starpost asd1");
      var m = Map.from(response.data);
      //print(m);
      print(m);
      print(m.runtimeType);
      print(response.statusCode);
      if (response.statusCode == 200) {
        res = "Success";
      }
      else{
        print("收藏失败");
      }
    }catch (exception) {
      print(exception);
      print("收藏失败");
    }
    return res;
  }

  Future<String> cancelStar(int postid,String uid) async {
    String res = "Fail";
    try{
      var dio = new Dio();
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      var response = await dio.post(gv.ip+"/api/star/cancelcollection",data: {
        "post_id":postid,
        "user_id":int.parse(uid),
      });
      print("cancelstar asd1");
      var m = Map.from(response.data);
      //print(m);
      print(m);
      print(m.runtimeType);
      print(response.statusCode);
      if (response.statusCode == 200) {
        res = "Success";
      }
      else{
        print("取消收藏失败");
      }
    }catch (exception) {
      print(exception);
      print("取消收藏失败");
    }
    return res;
  }
}
