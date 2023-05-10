//   TODO
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:frontend/Auth/customAuth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/user.dart';

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
      ).then((http.Response response) {
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
            'profile':'profile',
            'followers': [],
            'following': [],
          };
          CustomAuth.currentUser = User(
            username: data['username'] as String,
            password: data['password'] as String,
            uid: data['uid'] as String,
            jwt: data['jwt'] as String,
            photoUrl: data['photoUrl'] as String,
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
  Future<Map<String, dynamic>> getSomeMap(Uri url,String jwt) async{
    Map<String, dynamic> info = {};
    await _client.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: jwt,
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
  
  void changeInfo(String username,String nickname,String profile,String password,)async {
    Uri url = Uri.parse("http://127.0.0.1:5000/api/user/changeattr");
    print(username);
    print(profile);
    print(password);
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
          email: CustomAuth.currentUser.email,
          password: password,
          nickname: nickname,
          profile: profile,
          followers: CustomAuth.currentUser.followers,
          following: CustomAuth.currentUser.following);
        }
      }
    });
    if(password != CustomAuth.currentUser.password){
      url = Uri.parse("http://127.0.0.1:5000/api/user/resetpw");
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
            email: CustomAuth.currentUser.email,
            password: password,
            nickname: nickname,
            profile: profile,
            followers: CustomAuth.currentUser.followers,
            following: CustomAuth.currentUser.following);

        }
      });
    }
  }

  void uploadPhoto(Uint8List file) async {
    try{
      Uri url = Uri.parse("http://127.0.0.1:5000/api/user/uploadavatar");
      // FormData fd = FormData();
      // fd.appendBlob("photo", file as Blob);
      FormData fd = FormData.fromMap({
        "file":MultipartFile.fromBytes(file,filename:'asd.jpg',contentType: new MediaType("image", "jpeg")),
      });
      var dio = new Dio();
      var headers = {
        'Content-Type': 'multipart/form-data',
        HttpHeaders.authorizationHeader:CustomAuth.currentUser.jwt,
      };
      dio.options.headers['Content-Type']='multipart/form-data';
      dio.options.headers[HttpHeaders.authorizationHeader]=CustomAuth.currentUser.jwt;
      var response = await dio.post("http://127.0.0.1:5000/api/user/uploadavatar",data:fd,);
      String res = response.data.toString();

      print(res);
      print(res.runtimeType); // String

      var resJson = jsonDecode(res); // 字符串反序列化为Map
      print(resJson); // 此时\u5317\u4eac\u8317\u89c6\u5149的数据也被解码成了中文.
      print(resJson.runtimeType); //  _InternalLinkedHashMap<String, dynamic>
      // http.MultipartRequest request = new http.MultipartRequest('POST', url);
      // http.MultipartFile multipartFile = http.MultipartFile.fromBytes("photo", file);
      // request.files.add(multipartFile);
      // var headers = {
      //   'Content-Type': 'application/x-www-form-urlencoded',
      //   HttpHeaders.authorizationHeader:CustomAuth.currentUser.jwt,
      // };
      // request.headers.addAll(headers);
      //
      // http.StreamedResponse response = await request.send();
      // print(response.statusCode);
      // String res = await response.stream.bytesToString();
      // Map<String, dynamic> jsonResponse = jsonDecode(res) as Map<String, dynamic>;
      // print(jsonResponse['message']);
      if (response.statusCode == 200) {
        //这里返回值用到了Stream回调
        // String res = await response.stream.bytesToString();
        // Map<String, dynamic> jsonResponse = jsonDecode(res) as Map<String, dynamic>;
        // ResponseBase _responseBase = ResponseBase(
        //   errorCode: jsonResponse['errorCode'],
        //   action: jsonResponse['action'],
        //   message: jsonResponse['message'],
        //   value: jsonResponse['value'],
        //   success: jsonResponse['success'],
        // );
        // return _responseBase;
      }
    }catch (exception) {
      print("文件上传失败");
    }
  }

  void followUser(String uid) async {
    var url = Uri.parse("http://127.0.0.1:5000/api/user/register");
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
    url = Uri.parse("http://127.0.0.1:5000/api/user/followuser/"+uid);
    await _client.post(
      url,
      headers:{
        HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
        "content-type": ContentType.json.toString(),
      },
    ).then((http.Response response){
      print(jsonDecode(response.body)['message']);
    });
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
  register(Uri url, String name, String email, String password) async {
    Map<String, String> headersMap = new Map();
    headersMap["content-type"] = ContentType.json.toString();
    Map<String, String> bodyParams = new Map();
    bodyParams["nickname"] = name;
    bodyParams["username"] = email;
    bodyParams["password"] = password;
    var result="Fail";
    try{
      await _client.post(
          url,
          headers:headersMap,
          // body: bodyParams,
          body:jsonEncode({
            "nickname":name,
            "username":email,
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
  // Future<Map<String, dynamic>> getFollowers(Uri url,String jwt) async{
  //   Map<String, dynamic> userFollowers = {};
  //   await _client.get(
  //     url,
  //     headers: {
  //       HttpHeaders.authorizationHeader: jwt,
  //     },
  //   ).then((http.Response response) {
  //     //处理响应信息
  //     if (response.statusCode == 200) {
  //       userFollowers = jsonDecode(response.body);
  //     } else {
  //       print('error');
  //       print(response.body);
  //     }
  //   }).catchError((e){
  //     print(e);
  //   });
  //   return userFollowers;
  // }
  // Future<Map<String, dynamic>> getFollowed(Uri url,String uid,String jwt) async{
  //   Map<String, dynamic> userFollowed = {};
  //   await _client.get(
  //     url,
  //     headers: {
  //       HttpHeaders.authorizationHeader: jwt,
  //     },
  //   ).then((http.Response response) {
  //     //处理响应信息
  //     if (response.statusCode == 200) {
  //       userFollowed = jsonDecode(response.body);
  //     } else {
  //       print('error');
  //       print(response.body);
  //     }
  //   }).catchError((e){
  //     print(e);
  //   });
  //   return userFollowed;
  // }
}