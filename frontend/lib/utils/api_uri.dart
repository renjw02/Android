

String ip = "http://127.0.0.1";
String port = "5000";
var userLogin = Uri.parse( "$ip:$port/api/user/login");
var userRegister = Uri.parse("$ip:$port/api/user/register");
var feedsQueryUrl = Uri.parse("$ip:$port/api/getpostlist");