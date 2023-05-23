import 'dart:io';
import 'dart:convert';
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
    try {
      await _client.get(
          Uri.parse(url),
          headers: {
            HttpHeaders.authorizationHeader: CustomAuth.currentUser.jwt,
            'Content-Type': 'application/json'
          },
      ).then((http.Response response) {
        if (response.statusCode == 200) {
          res =  jsonDecode(response.body);
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
}