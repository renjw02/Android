const webScreenSize = 600;

const String serverIp = "http://183.172.230.189";
const String serverPort = "5000";
const ip = "$serverIp:$serverPort";
var userLogin = Uri.parse( "$serverIp:$serverPort/api/user/login");
var userRegister = Uri.parse("$serverIp:$serverPort/api/user/register");
var feedsQueryUrl = Uri.parse("$serverIp:$serverPort/api/getpostlist");
var noticeListQueryUrl = Uri.parse("$serverIp:$serverPort/api/notice/getnoticelist");
