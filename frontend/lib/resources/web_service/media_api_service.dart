import './api_service.dart' ;
import '../../utils/global_variable.dart' as gv;

enum MediaType { image, video }

class MediaApiService extends ApiService {

  Future<List<String>> getMediaUrls(MediaType type, int postId) async {
    String url = '/api/post/';
    if(type == MediaType.image) {
      url += 'getpictureslist';
    }else{
      url += 'getvideoslist';
    }
    url += '/$postId';
    print('getMediaUrls: $url');
    var result = await sendGetRequest(url, {});
    print('getMediaUrls: $result');
    print(result);
    List<String> mediaUrls = [];
    for (var i = 0; i < result.length; i++) {
      mediaUrls.add(result[i]);
    }
    //将每个url前面加上ip,port
    if (type == MediaType.image)
      mediaUrls = mediaUrls.map((e) => "${gv.ip}/api/media/photo?name=$e").toList();
    else
      mediaUrls = mediaUrls.map((e) => "${gv.ip}/api/media/video?name=$e").toList();
    print("getMediaUrls:");
    print(mediaUrls);
    return mediaUrls;
  }

  Future<List<String>> getImageUrls(int postId) async {
    return getMediaUrls(MediaType.image, postId);
  }
  Future<List<String>> getVideoUrls(int postId) async {
    return getMediaUrls(MediaType.video, postId);
  }
}
