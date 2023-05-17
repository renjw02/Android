

String ip = "http://183.173.187.204";
String port = "5000";
var userLogin = Uri.parse( "$ip:$port/api/user/login");
var userRegister = Uri.parse("$ip:$port/api/user/register");
var feedsQueryUrl = Uri.parse("$ip:$port/api/getpostlist");
var noticeListQueryUrl = Uri.parse("$ip:$port/api/notice/getnoticelist");