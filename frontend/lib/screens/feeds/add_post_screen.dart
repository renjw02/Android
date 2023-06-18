import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:geolocator/geolocator.dart';

import '../../resources/database_methods.dart' as db;
import '../../widgets/full_Video.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool isLoading = false;
  String topicContent = "选择一个话题";
  int fontSize = 16;
  Color fontColor = Colors.white;
  var fontWeight = FontWeight.w500;  //fontWeight: FontWeight.w100 ~ w900
  String position = "位置";
  final TextEditingController titlec = TextEditingController();
  final TextEditingController contentc = TextEditingController();
  List<Uint8List> photos = [];
  List<Uint8List> videos = [];
  List<Uint8List> files = [];
  List<int> fileTypes = [];     //0为图片，1为视频
  Map<int,Uint8List> videonails = {};   //视频缩略图
  String _locationMessage = "position";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose(){
    super.dispose();
    titlec.dispose();
    contentc.dispose();
  }

  void _getCurrentLocation() async {
    if (kDebugMode) {
      print("getcurrentlocation");
    }
    if (kDebugMode) {
      print("asd");
    }
    final position1 = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (kDebugMode) {
      print("asd");
      print(position1);
      print("asd");
    }
    List<Placemark> placemarks = await placemarkFromCoordinates(position1.latitude, position1.longitude);
    Placemark place = placemarks[0];
    if (kDebugMode) {
      print("asd");
    }

    setState(() {
      _locationMessage = "${place.locality}, ${place.street}, ${place.country},${place.administrativeArea},""${place.name},${place.subAdministrativeArea},${place.subLocality},${place.thoroughfare},${place.subThoroughfare}";
      position = place.street!;
    });
    if (kDebugMode) {
      print(_locationMessage);
    }
  }

  _selectImage(BuildContext parentContext) async {
    if(files.length==9){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("最多只能添加9张图片或视频哦"),
        ),
      );
      return;
    }
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('添加图片'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('拍照'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    //photos.add(file);
                    files.add(file);
                    fileTypes.add(0);
                    if (kDebugMode) {
                      print(files.length);
                    }
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('上传本地图片'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    files.add(file);
                    fileTypes.add(0);
                    if (kDebugMode) {
                      print(files.length);
                    }
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("取消"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  _selectVideo(BuildContext parentContext) async {
    if(files.length==9){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("最多只能添加9张图片或视频哦"),
        ),
      );
      return;
    }
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('添加视频'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('录像'),
                onPressed: () async {
                  Navigator.pop(context);
                  List<Uint8List> file = await pickVideo(ImageSource.camera);
                  setState((){
                    files.add(file[0]);
                    fileTypes.add(1);
                    if (kDebugMode) {
                      print(files.length);
                    }
                    videonails[files.length-1] = file[1];
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('上传本地视频'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  List<Uint8List> file = await pickVideo(ImageSource.gallery);
                  setState((){
                    files.add(file[0]);
                    fileTypes.add(1);
                    if (kDebugMode) {
                      print(files.length);
                    }
                    videonails[files.length-1] = file[1];
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("取消"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  buildTable() {
    if (kDebugMode) {
      print("buildtable");
      print(fileTypes);
    }
    if(files==null){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_photo_alternate,
            ),
            onPressed: ()async{
              await _selectImage(context);
              setState(() {});
            }
         ),
        IconButton(
            icon: const Icon(
              Icons.video_call,
            ),
            onPressed: ()async{
              await _selectVideo(context);
              setState(() {});
            }
        ),
        ]
      );
    }
    List<Container> arow = [];
    int count = 0;
    for(var file in files){
      if(fileTypes[count]==0){
        int temp = count;
        arow.add(
          Container(
            margin: const EdgeInsets.all(10.0), // 设置边距
            child:GestureDetector(
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) =>
                      Scaffold(
                        backgroundColor: Colors.black87,
                        body: GestureDetector(
                          child: Center(
                            child: PhotoView(
                              imageProvider: MemoryImage(file)
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        )
                      )
                  )
                );
              },
              onDoubleTap: (){
                files.removeAt(temp);
                fileTypes.removeAt(temp);
                setState(() {
                });
              },
              child:
              ClipRRect(
                  borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width*0.3,
                    child: Image.memory(file,fit: BoxFit.cover),
                  )
              ),
            )
          ),
        );
      }
      else{
        if (kDebugMode) {
          print("get a video");
        }
        int temp = count;
        arow.add(
          Container(
            margin: const EdgeInsets.all(10.0), // 设置边距
              child:GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => FullVideoWidget(videoFile: file),
                      )
                  );
                },
                onDoubleTap: (){
                  files.removeAt(temp);
                  fileTypes.removeAt(temp);
                  videonails.remove(temp);
                  setState(() {
                  });
                },
                child:
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child:
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width*0.3,
                            child: Image.memory(videonails[count]!,fit: BoxFit.cover),
                          )
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Icon(Icons.play_circle,color: Colors.white,size: MediaQuery.of(context).size.width*0.1,),
                    )
                  ],
                )
              )
          )
        );
      }
      count++;
    }
    return Expanded(child:
    Column(
      children:[
        Expanded(child:GridView.count(
          scrollDirection: Axis.vertical,
          crossAxisCount: 3,
          shrinkWrap: true,
          children: arow,
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(
                Icons.add_photo_alternate,
              ),
              onPressed: ()async{
                await _selectImage(context);
                setState(() {});
              }
            ),
            IconButton(
              icon: const Icon(
                Icons.video_call,
              ),
              onPressed: ()async{
                await _selectVideo(context);
                setState(() {});
              }
            ),
          ]
        ),
      ]
    )
    );
  }

  _selectTopic(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('选择一个话题'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('校园资讯'),
                onPressed: () {
                  Navigator.pop(context);
                  topicContent = "校园资讯";
                  setState(() {

                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('二手交易'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  topicContent = "二手交易";
                  setState(() {

                  });
                }),
          ],
        );
      },
    );
  }


  void clearInfo() {
    setState(() {
      topicContent = "选择一个话题";
      fontSize = 16;
      fontColor = Colors.white;
      fontWeight = FontWeight.w500;
      titlec.text = "";
      contentc.text = "";
      //photos = [];
      files = [];
      fileTypes = [];
    });
  }
  
  void post() async {
    try{
      Map<String ,int> topic2type = {"校园资讯":1,"二手交易":2};
      if(files == null){
        if (kDebugMode) {
          print("file is null");
        }
      }
      List<Uint8List?> postfiles = files;
      if (kDebugMode) {
        print(topic2type[topicContent]!);
      }
      Map<Color,String> colors = {Colors.red:"red",Colors.white:"white",Colors.yellow:"yellow"};
      Map<FontWeight,String> weights = {FontWeight.w300:"较细",FontWeight.w500:"适中",FontWeight.w700:"较粗"};
      String res = await db.DataBaseManager().createPost(titlec.text, contentc.text, topic2type[topicContent]!, "$position",
          fontSize,colors[fontColor]!,weights[fontWeight]!,postfiles,fileTypes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res),
        ),
      );
      if (kDebugMode) {
        print(res);
      }
      if(res=="动态上传成功"){
        setState(() {
          topicContent = "选择一个话题";
          fontSize = 16;
          fontColor = Colors.white;
          fontWeight = FontWeight.w500;
          titlec.text = "";
          contentc.text = "";
          photos = [];
          fileTypes = [];
          files = [];
        });
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("请填写动态类型、标题及内容"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            backgroundColor: mobileBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.cleaning_services_rounded),
              onPressed: clearInfo,
            ),
            title: const Text(
              '发布帖子',
            ),
            centerTitle: true,
            actions: <Widget>[
              TextButton(
                onPressed: () => post(),
                child: const Text(
                  "发布",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              )
            ],
          ),
      body:Container(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    //do something on tap
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0,left: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          position,
                          style: const TextStyle(
                            fontSize:11,
                            color: Colors.grey,
                            overflow: TextOverflow.ellipsis,
                          ),

                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 80),
                    child: IconButton(
                      icon: const Icon(Icons.topic),
                      onPressed: () => _selectTopic(context),
                      iconSize: 30,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 80),
                      child: TextButton(
                        onPressed: () => _selectTopic(context),
                        child: Text(
                          topicContent,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            Row(
                children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.33,
                  child: DropdownButton(
                    value: fontSize, //style: style,
                    icon: const Icon(Icons.arrow_drop_down), iconSize: 30, iconEnabledColor: Colors.deepPurple.withOpacity(0.7),
                    hint: const Text('请选择地区'), isExpanded: true,
                    underline: Container(height: 1, color: Colors.deepPurple.withOpacity(0.7)),
                    items: const [
                    DropdownMenuItem(
                    value: 12,
                    child: Row(children: <Widget>[Icon(Icons.text_fields, color: Colors.deepPurple),SizedBox(width: 20),
                      Text('小字体',style: TextStyle(fontSize: 12)), SizedBox(width: 5)])),
                    DropdownMenuItem(
                    value: 16,
                    child: Row(children: <Widget>[Icon(Icons.text_fields, color: Colors.deepPurple),SizedBox(width: 15),Text('适中',style: TextStyle(fontSize: 16)), SizedBox(width: 5)])),
                    DropdownMenuItem(
                    value: 20,
                    child: Row(children: <Widget>[Icon(Icons.text_fields, color: Colors.deepPurple),SizedBox(width: 5),Text('大字体', style: TextStyle(fontSize: 20)), SizedBox(width: 5)]))
                    ],
                    onChanged: (value) => setState(() => fontSize = value!)
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.03),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.25,
                  child: DropdownButton(
                      value: fontColor, //style: style,
                      icon: const Icon(Icons.arrow_drop_down), iconSize: 30, iconEnabledColor: Colors.red.withOpacity(0.7),
                      hint: const Text('请选择字体颜色'), isExpanded: true, underline: Container(height: 1, color: Colors.red.withOpacity(0.7)),
                      items: const [
                        DropdownMenuItem(
                            value: Colors.red,
                            child: Row(children: <Widget>[Icon(Icons.color_lens, color: Colors.red),
                              SizedBox(width: 5),Text('红色',style: TextStyle(color: Colors.red, fontSize: 16)), SizedBox(width: 5)])),
                        DropdownMenuItem(
                            value: Colors.white,
                            child: Row(children: <Widget>[Icon(Icons.color_lens, color: Colors.white),
                              SizedBox(width: 5),Text('白色',style: TextStyle(color: Colors.white, fontSize: 16)), SizedBox(width: 5)])),
                        DropdownMenuItem(
                            value: Colors.yellow,
                            child: Row(children: <Widget>[Icon(Icons.color_lens, color: Colors.yellow),
                              SizedBox(width: 5),Text('黄色', style: TextStyle(color: Colors.yellow, fontSize: 16)), SizedBox(width: 5)]))
                      ],
                      onChanged: (value) => setState(() => fontColor = value!)
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.03),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.25,
                  child: DropdownButton(
                      value: fontWeight, //style: style,
                      icon: const Icon(Icons.arrow_drop_down), iconSize: 30, iconEnabledColor: Colors.teal.withOpacity(0.7),
                      hint: const Text('请选择字体粗细'), isExpanded: true, underline: Container(height: 1, color: Colors.teal.withOpacity(0.7)),
                      items: const [
                        DropdownMenuItem(
                            value: FontWeight.w300,
                            child: Row(children: <Widget>[Icon(Icons.format_bold, color: Colors.teal),
                              SizedBox(width: 5),Text('较细', style: TextStyle(fontWeight: FontWeight.w300)), SizedBox(width: 5) ])),
                        DropdownMenuItem(
                            value: FontWeight.w500,
                            child: Row(children: <Widget>[Icon(Icons.format_bold, color: Colors.teal),
                              SizedBox(width: 5),
                              Text('适中', style: TextStyle(fontWeight: FontWeight.w500)), SizedBox(width: 5)])),
                        DropdownMenuItem(
                            value: FontWeight.w700,
                            child: Row(children: <Widget>[Icon(Icons.format_bold, color: Colors.teal),
                              SizedBox(width: 5),
                              Text('较粗', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(width: 5)]))
                      ],
                      onChanged: (value) => setState(() => fontWeight = value!)
                  ),
                ),
                ]
              ),

            TextField(
                controller: titlec,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "如何评价",
                  labelText: "标题",
                  prefixIcon: Icon(Icons.title),
                ),
                maxLines: 1,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: contentc,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "请输入内容",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          buildTable(),
        ],
      ),
    ));
  }
}
