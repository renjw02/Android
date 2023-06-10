/// A Flutter component to display a video thumbnail and play the video.
///
/// This component first caches the video, generates a thumbnail image file,
/// displays the thumbnail. When tapped, it plays the video.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/global_variable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../resources/database_methods.dart' as db;
import '../Auth/customAuth.dart';
import '../resources/web_service/media_api_service.dart';
import 'full_Video.dart';

/// The [VideoComponent] widget.
class VideoComponent extends StatefulWidget {
  /// The URL of the video.
  final String videoUrl;
  late final filePath;
  late final _file;
  /// Constructs a [VideoComponent].
  ///
  /// The [videoUrl] parameter is required.
  VideoComponent({required this.videoUrl});

  @override
  _VideoComponentState createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
  /// The [VideoPlayerController] for the video.
  VideoPlayerController? _controller;

  /// The file path of the cached thumbnail image.
  String? _thumbnailFile;

  @override
  void initState() {
    super.initState();
    /// Cache the video and generate a thumbnail file.
    _cacheVideo();
  }


  Map<String, String> extractParams(String url) {
    var params = <String, String>{};
    var uri = Uri.parse(url);
    var query = uri.queryParameters;
    params['path'] = uri.path;
    params['name'] = query['name']!;
    return params;
  }

  /// Cache the video from the URL and generate a thumbnail image file.
  _cacheVideo() async {
    print('videoUrl: ${widget.videoUrl}');
    Map<String, String> params = extractParams(widget.videoUrl);
    print('params: $params');
    // Download the video data
    List<int> videoBytes = await MediaApiService().getMedia(params['path']!, params['name']!);

    // Decode the Base64 encoded video data
    // List<int> videoBytes = base64Decode(videoData);
    print('videoBytes: $videoBytes');
    // Get the temporary directory
    var tempDir = await getTemporaryDirectory();

    // Generate a file name with timestamp
    String fileName = 'video_${DateTime.now().millisecond}.mp4';
    widget.filePath = '${tempDir.path}/$fileName';

    // Create and write the video file
    widget._file = await File(widget.filePath).create();
    widget._file.writeAsBytesSync(videoBytes);

    // Initialize the VideoPlayerController
    _controller = VideoPlayerController.file(
      widget._file,
    );

    await _controller?.initialize();

    // Generate and save the thumbnail file
    final thumbnailFile = await _saveThumbnailFile(widget.filePath);
    _thumbnailFile = thumbnailFile;

    setState(() {});
  }

  /// Generate a thumbnail image file from the video.
  _saveThumbnailFile(filePath) async {
    final file = await VideoThumbnail.thumbnailFile(
      /// The URL of the video
        video: filePath,

        /// The output directory for the thumbnail
        thumbnailPath: (await getTemporaryDirectory()).path,

        /// The image format of the thumbnail
        imageFormat: ImageFormat.JPEG,

        /// The maximum width of the thumbnail
        maxWidth: 128,

        /// The quality of the thumbnail image
        quality: 100
    );
    return file;
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    widget._file?.delete();

  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // _controller?.play();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayPage(controller: _controller! ),
          ),
        );
        setState(() {});
      },
      child: _thumbnailFile == null
          ? const Center(
            child:CircularProgressIndicator()
          )
          : Stack(
        children: [
          // Image.file(File(_thumbnailFile!)),
          _controller != null && _controller!.value.isInitialized
              ? Center(
                child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
          ),
              )
              : const Center(
              child:CircularProgressIndicator()
          ),
          const Center(
            child: Icon(
              Icons.play_circle_filled,
              size: 60,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}

class VideoPlayPage extends StatefulWidget {
  VideoPlayerController controller;
  VideoPlayPage({required this.controller});

  @override
  _VideoPlayPageState createState() => _VideoPlayPageState();
}

class _VideoPlayPageState extends State<VideoPlayPage> {

  @override
  void initState() {
    super.initState();
    widget.controller.initialize().then((_) {
        widget.controller.play();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: VideoPlayer(widget.controller),
        )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            widget.controller.value.isPlaying
                ? widget.controller.pause()
                : widget.controller.play();
          });
        },
        child: Icon(
          widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}