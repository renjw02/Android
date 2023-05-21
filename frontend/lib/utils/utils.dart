import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// for picking up image from gallery
pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  }
  print('No Image Selected');
}

pickVideo(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickVideo(source: source);
  if (_file != null) {
    File videoThumbnailFile = await _getVideoThumbnail(_file!);
    return [await _file.readAsBytes(),await videoThumbnailFile.readAsBytes()];
  }
  print('No Video Selected');
}

Future<File> _getVideoThumbnail(XFile videoFile) async {
  Uint8List? thumbnail = await VideoThumbnail.thumbnailData(
    video: videoFile.path,
    imageFormat: ImageFormat.JPEG,
    quality: 25,
  );
  var tempDir = await getTemporaryDirectory();
  //生成file文件格式
  String videoThumbnail = '${tempDir.path}/image_${DateTime.now().millisecond}.jpg';
  var file = await File(videoThumbnail).create();
  file.writeAsBytesSync(thumbnail!);
  return file;
}

// for displaying snackbars
showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}
