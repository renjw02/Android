import 'dart:typed_data';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:new_chat/service/screen_adapter.dart';
// import 'package:new_chat/widget/toast_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerFromFile extends StatefulWidget {
  final Uint8List videoFile;

  const VideoPlayerFromFile({Key? key, required this.videoFile}) : super(key: key);

  @override
  State<VideoPlayerFromFile> createState() => _VideoPlayerFromFileState();
}

class _VideoPlayerFromFileState extends State<VideoPlayerFromFile> {
  late VideoPlayerController _controller;

  //视频总时长
  String videoPlayerEndTime = "";

  //视频正在播放的时长
  String videoPlayerTime = "";
  bool isLoading = false;

  @override
  void initState() {
    initController();
    super.initState();
  }

  void initController()async{
    setState(() {
      isLoading = true;
    });
    var tempDir = await getTemporaryDirectory();
    //生成file文件格式
    String video = '${tempDir.path}/video_${DateTime.now().millisecond}.mp4';
    var file = await File(video).create();
    file.writeAsBytesSync(widget.videoFile);
    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
    _controller.addListener(() {
      setState(() {
        //拼接视频总时长
        int endMinutes = _controller.value.duration.inMinutes;
        //不足2位补0
        var endMinutesPadLeft = endMinutes.toString().padLeft(2,"0");
        int endSeconds = _controller.value.duration.inSeconds;
        var endSecondsPadLeft = endSeconds.toString().padLeft(2,"0");
        videoPlayerEndTime = "$endMinutesPadLeft:$endSecondsPadLeft";
        int videoPlayerMinutes = _controller.value.position.inMinutes;
        var videoPlayerMinutesPadLeft = videoPlayerMinutes.toString().padLeft(2,"0");
        int videoPlayerSeconds = _controller.value.position.inSeconds;
        var videoPlayerSecondsPadLeft = videoPlayerSeconds.toString().padLeft(2,"0");
        videoPlayerTime = "$videoPlayerMinutesPadLeft:$videoPlayerSecondsPadLeft";
      });
    });
    setState(() {
      isLoading = false;
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return isLoading?
    const Center(
      child: CircularProgressIndicator(),
    )
        :Scaffold(
        backgroundColor: Colors.black87,
        body:
        Stack(
          children: [
            //视频内容
            Align(
              child: Container(
                child: _controller.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                    : Container(),
              ),
            ),
            //播放暂定和播放进度条和视频时间
            Container(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                        EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),
                        child: GestureDetector(
                          onTap: () {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          },
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_outlined
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width * 0.05,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                        EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
                        child: Text(
                          videoPlayerTime,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                              playedColor: Colors.white,
                              bufferedColor: Colors.white10,
                              backgroundColor: Colors.black26),
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.05,
                              0,
                              MediaQuery.of(context).size.width * 0.05,
                              0),
                        ),
                      ),
                      Container(
                        padding:
                        EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.05),
                        child: Text(
                          videoPlayerEndTime,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )),
            ),
            //关闭视频按钮
            Align(
              alignment: Alignment.topRight,
              child:Container(
                padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.1,MediaQuery.of(context).size.height * 0.05,0,0),
                child:  GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.cancel,color: Colors.white,size: MediaQuery.of(context).size.width * 0.1,),
                ),),),
          ],
        )
    );
  }
}