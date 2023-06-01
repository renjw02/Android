import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:frontend/utils/global_variable.dart';
import 'package:http/http.dart' as http;
import '../../Auth/customAuth.dart';


class ApiService {
  static final _client = http.Client();

  Future<String> sendPostRequest(String url, Map<String, dynamic> body) async {
    String res = 'Failed';
    try {
      await _client.post(
          Uri.parse("$serverIp:$serverPort$url"),
          headers: {
            HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(body)
      ).then((http.Response response) {
        print('response.statusCode: ${response.statusCode}');
        print(jsonDecode(response.body)['message']);
        if (response.statusCode == 200) {
          print(jsonDecode(response.body)['message']);
          res = jsonDecode(response.body)['message'];
        }
      }).catchError((error) {
        print('catchError:');
        print(error);
      });
    } catch (e) {
      print(e);
    }
    return res;
  }

  Future<dynamic> sendGetRequest(String url, Map<String, dynamic> body) async {
    var res;
    print('sendGetRequest');
    print(body);
    try {
      // await _client.get(
      //     Uri.parse("$serverIp:$serverPort$url"),
      //     headers: {
      //       HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
      //       'Content-Type': 'application/json'
      //     },
      // ).then((http.Response response) {
      //   if (response.statusCode == 200) {
      //     res =  jsonDecode(response.body);
      //     print('res: $res');
      //   }
      // }).catchError((error) {
      //   print('catchError:');
      //   print(error);
      // });
      final dio = Dio();
      final response = await dio.get(
          "$serverIp:$serverPort$url",
          queryParameters: body,
          options: Options(
              headers: {
                HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
                'Content-Type': 'application/json'
              }
          )
      );
      if (response.statusCode == 200) {
        res = response.data;
      }else{
        print('response.statusCode: ${response.statusCode}');
        print(response.data);
        print(response.data['message']);
      }
    } catch (e) {
      print(e);
    }
    return res;
  }
}