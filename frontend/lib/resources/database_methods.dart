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

import '../models/user.dart';
import '../utils/global_variable.dart'as gv;

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
          following: CustomAuth.currentUser.following);
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
            following: CustomAuth.currentUser.following);
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
    var url = Uri.parse(gv.ip+"/api/user/register");
    await _client.post(
      url,
      headers:{
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
        "content-type": ContentType.json.toString(),
      },
      // body: bodyParams,
      body:jsonEncode({
        "username":"username",
        "nickname":"nickname",
        "password":"password",
      }),
    ).then((http.Response response){
      print(jsonDecode(response.body)['message']);
      print(jsonDecode(response.body)['userId']);
    });
    url = Uri.parse(gv.ip+"/api/user/followuser/"+uid);
    await _client.post(
      url,
      headers:{
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
        "content-type": ContentType.json.toString(),
      },
    ).then((http.Response response){
      print(jsonDecode(response.body));
      if(CustomAuth.currentUser.following.indexOf(jsonDecode(response.body)['followed_id']) == -1){
        CustomAuth.currentUser.following.add(jsonDecode(response.body)['followed_id']);
      }
      print(jsonDecode(response.body)['message']);
    });
  }

  Future<String> createPost(String title,String content,int type,String position,int font_size,String font_color,
  String font_weight,List<Uint8List?> files) async {
    String res = "动态上传失败";
    try{
      List<MultipartFile> mfiles=[];
      int count=0;
      for(Uint8List? file in files){
        if(file != null){
          mfiles.add(MultipartFile.fromBytes(file,filename:'${title}${count}.jpg',contentType: new MediaType("image", "jpeg")));
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

  Future<List<dynamic>> getPost([int page=1,int size=10,int userId=0,String? orderByWhat=null,int type=0,bool? onlyFollowing=null,
    bool? hot=null]) async {
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
      print(paras);
      var response = await dio.get(gv.ip+"/api/post/getpostlist",queryParameters: paras);
      print("asd1");
      print(response.data);
      print(response.data.runtimeType);
      var m = Map.from(response.data);
      print(m);
      print(m.runtimeType);
      print(response.statusCode);
      print(response.statusCode.runtimeType);
      if (response.statusCode == 200) {
        return m['posts'];
      }
      else{
        print("获取动态失败");
        return [];
      }
    }catch (exception) {
      print(exception);
      print("获取动态错误");
      return [];
    }
  }

  Future<Map<String,dynamic>?> getThePost(int id) async{
    try{
      var dio = new Dio();
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      var response = await dio.get(gv.ip+"/api/post/getpost/"+id.toString());
      print("getthepost asd1");
      // print(response.data);
      // print(response.data.runtimeType);
      var m = Map.from(response.data);
      //print(m);
      print(m.runtimeType);
      print(response.statusCode);
      print(response.statusCode.runtimeType);
      Map<String,dynamic> result = {};
      if (response.statusCode == 200) {
        result['images'] = m['images'];
        result['videos'] = m['videos'];
        return result;
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

  // ### 注册
  // @bp.route('register', methods=['POST'])
  // def user_register():
  //
  // + 接收：json
  // {
  // "username"    只能大小写字母、数字、*-_@
  // "password"    必须字母+数字，不能有其他
  // "nickname"    任意，不超过14字符
  // }
  // + 返回：json + 状态码
  // {
  // "message"
  // "userId"
  // "username"
  // "nickname"
  // }
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
}