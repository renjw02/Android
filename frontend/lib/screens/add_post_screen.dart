import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/resources/post_methods.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';

import '../resources/database_methods.dart' as db;
import '../widgets/full_Video.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  String topicContent = "选择一个话题";
  //LocationData? currentLocation;
  Address? address;
  int font_size = 16;
  Color font_color = Colors.white;
  var font_weight = FontWeight.w500;  //fontWeight: FontWeight.w100 ~ w900
  Position? position;
  final TextEditingController titlec = new TextEditingController();
  final TextEditingController contentc = new TextEditingController();
  List<Uint8List> photos = [];
  List<Uint8List> videos = [];
  List<Uint8List> files = [];
  List<int> fileTypes = [];     //0为图片，1为视频
  Map<int,Uint8List> videonails = {};   //视频缩略图

  @override
  void initState() {
    super.initState();

    // print("getlocation");
    // Geolocator.getLastKnownPosition().then((value){
    //   if(value == null){
    //     print("last is null");
    //     Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((Position p){
    //       position = p;
    //     });
    //   }
    //   else{
    //     position = value;
    //   }
    //   // Geolocator.
    //   // var coordinates = new Coordinates(position.latitude, position.longitude);
    //   // var addresses = await GeoCode.local.findAddressesFromCoordinates(coordinates);
    //   // first = addresses.first;
    //   // print("${first.featureName} : ${first.addressLine}");
    //   print(position);
    //   getaddress(position!.latitude, position!.longitude);
    //   print(address);
    // }).catchError((onError){
    //   print("error");
    //   print(onError);
    // });
  }

  @override
  void dispose(){
    super.dispose();
    titlec.dispose();
    contentc.dispose();
  }

  void getaddress(double lat,double lang) async {
    GeoCode geoCode = GeoCode();
    address = await geoCode.reverseGeocoding(latitude: lat, longitude: lang);
  }

  Future<String> _getAddress(double? lat, double? lang) async {
    if (lat == null || lang == null) return "";
    GeoCode geoCode = GeoCode();
    Address address =
    await geoCode.reverseGeocoding(latitude: lat, longitude: lang);
    //return "${address.streetAddress}, ${address.city}, ${address.countryName}, ${address.postal}";
    return "${address.city}, ${address.countryName}";
  }

  _selectImage(BuildContext parentContext) async {
    if(files.length==9){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
                    print(files.length);
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
                    print(files.length);
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
        SnackBar(
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
                    print(files.length);
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
                    print(files.length);
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
    print("buildtable");
    print(fileTypes);
    if(files==null){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(
              Icons.image,
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
        print("get a video");
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
                // SizedBox(
                //     height: MediaQuery.of(context).size.height * 0.12,
                //     width: MediaQuery.of(context).size.width*0.1,
                //     child:Stack(
                //         children:[
                //           Align(
                //             alignment: Alignment.center,
                //             child: ClipRRect(
                //               borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
                //               child: Image.memory(videonails[count]!,fit: BoxFit.fill),
                //             ),
                //           ),
                //           Align(
                //             alignment: Alignment.center,
                //             child: Icon(Icons.play_circle,color: Colors.white,size: MediaQuery.of(context).size.width*0.1,),
                //           )
                //         ]
                //     )
                // ),
              )
            // child:ListView(
            //   shrinkWrap: true,
            //   children: [
            //     GestureDetector(
            //       onTap: () {
            //         Navigator.push(context,
            //           MaterialPageRoute(
            //             builder: (context) => FullVideoWidget(videoFile: file),
            //           )
            //         );
            //       },
            //       onDoubleTap: (){
            //         files.remove(file);
            //         setState(() {
            //         });
            //       },
            //       child:
            //         SizedBox(
            //           height: MediaQuery.of(context).size.height * 0.12,
            //           width: MediaQuery.of(context).size.width*0.1,
            //           child:Stack(
            //               children:[
            //                 Align(
            //                   alignment: Alignment.center,
            //                   child: ClipRRect(
            //                     borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
            //                     child: Image.memory(videonails[count]!,fit: BoxFit.fill),
            //                   ),
            //                 ),
            //                 Align(
            //                   alignment: Alignment.center,
            //                   child: Icon(Icons.play_circle,color: Colors.white,size: MediaQuery.of(context).size.width*0.1,),
            //                 )
            //               ]
            //           )
            //         ),
            //     )
            //   ],
            // )
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
                Icons.image,
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
      font_size = 16;
      font_color = Colors.white;
      font_weight = FontWeight.w500;
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
        print("file is null");
      }
      List<Uint8List?> postfiles = files;
      print(topic2type[topicContent]!);
      Map<Color,String> colors = {Colors.red:"red",Colors.white:"white",Colors.yellow:"yellow"};
      Map<FontWeight,String> weights = {FontWeight.w300:"较细",FontWeight.w500:"适中",FontWeight.w700:"较粗"};
      String res = await db.DataBaseManager().createPost(titlec.text, contentc.text, topic2type[topicContent]!, "position",
          font_size,colors[font_color]!,weights[font_weight]!,postfiles,fileTypes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res),
        ),
      );
      print(res);
      if(res=="动态上传成功"){
        setState(() {
          topicContent = "选择一个话题";
          font_size = 16;
          font_color = Colors.white;
          font_weight = FontWeight.w500;
          titlec.text = "";
          contentc.text = "";
          photos = [];
          fileTypes = [];
          files = [];
        });
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("请填写动态类型、标题及内容"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment:MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.topic,
                  ),
                  onPressed: () => _selectTopic(context),
                ),
                Text("${topicContent}"),
                // if (currentLocation != null)
                // Text("Location: ${currentLocation?.latitude}, ${currentLocation?.longitude}"),
                const Divider(),
                //if (currentLocation != null) Text("Address: $address"),
              ],
            ),
            Column(
              children: [
              DropdownButton(
                value: font_size, //style: style,
                icon: Icon(Icons.arrow_right), iconSize: 40, iconEnabledColor: Colors.green.withOpacity(0.7),
                hint: Text('请选择地区'), isExpanded: true, underline: Container(height: 1, color: Colors.green.withOpacity(0.7)),
                items: [
                DropdownMenuItem(
                child: Row(children: <Widget>[Text('小字体',style: TextStyle(fontSize: 12)), SizedBox(width: 10)]),
                value: 12),
                DropdownMenuItem(
                child: Row(children: <Widget>[Text('适中',style: TextStyle(fontSize: 16)), SizedBox(width: 10)]),
                value: 16),
                DropdownMenuItem(
                child: Row(children: <Widget>[Text('大字体', style: TextStyle(fontSize: 20)), SizedBox(width: 10)]),
                value: 20)
                ],
                onChanged: (value) => setState(() => font_size = value!)
              ),
              DropdownButton(
                  value: font_color, //style: style,
                  icon: Icon(Icons.arrow_right), iconSize: 40, iconEnabledColor: Colors.red.withOpacity(0.7),
                  hint: Text('请选择字体颜色'), isExpanded: true, underline: Container(height: 1, color: Colors.green.withOpacity(0.7)),
                  items: [
                    DropdownMenuItem(
                        child: Row(children: <Widget>[Text('红色',style: TextStyle(color: Colors.red, fontSize: 16)), SizedBox(width: 10)]),
                        value: Colors.red),
                    DropdownMenuItem(
                        child: Row(children: <Widget>[Text('白色',style: TextStyle(color: Colors.white, fontSize: 16)), SizedBox(width: 10)]),
                        value: Colors.white),
                    DropdownMenuItem(
                        child: Row(children: <Widget>[Text('黄色', style: TextStyle(color: Colors.yellow, fontSize: 16)), SizedBox(width: 10)]),
                        value: Colors.yellow)
                  ],
                  onChanged: (value) => setState(() => font_color = value!)
              ),
              DropdownButton(
                  value: font_weight, //style: style,
                  icon: Icon(Icons.arrow_right), iconSize: 40, iconEnabledColor: Colors.blue.withOpacity(0.7),
                  hint: Text('请选择字体粗细'), isExpanded: true, underline: Container(height: 1, color: Colors.green.withOpacity(0.7)),
                  items: [
                    DropdownMenuItem(
                        child: Row(children: <Widget>[Text('较细', style: TextStyle(fontWeight: FontWeight.w300)), SizedBox(width: 10) ]),
                        value: FontWeight.w300),
                    DropdownMenuItem(
                        child: Row(children: <Widget>[Text('适中', style: TextStyle(fontWeight: FontWeight.w500)), SizedBox(width: 10)]),
                        value: FontWeight.w500),
                    DropdownMenuItem(
                        child: Row(children: <Widget>[Text('较粗', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(width: 10)]),
                        value: FontWeight.w700)
                  ],
                  onChanged: (value) => setState(() => font_weight = value!)
              ),

              ]

            ),
            TextField(
              controller: titlec,
              decoration: const InputDecoration(
                hintText: "如何评价",
                labelText: "标题",
                prefixIcon: Icon(Icons.title),
              ),
              maxLines: 1,
          ),
            TextField(
              controller: contentc,
              decoration: const InputDecoration(
                hintText: "如何评价",
                labelText: "内容",
                prefixIcon: Icon(Icons.content_copy),
              ),
              maxLines: null,
              minLines: 1,
            ),
          buildTable(),

          // _file == null?
          // Center(
          //   child: IconButton(
          //     icon: const Icon(
          //       Icons.upload,
          //     ),
          //     onPressed: () => _selectImage(context),
          //   ),
          // ):SizedBox(
          //   height: 45.0,
          //   width: 45.0,
          //   child: AspectRatio(
          //     aspectRatio: 487 / 451,
          //     child: Container(
          //       decoration: BoxDecoration(
          //           image: DecorationImage(
          //             fit: BoxFit.fill,
          //             alignment: FractionalOffset.topCenter,
          //             image: MemoryImage(_file!),
          //           )),
          //     ),
          //   ),
          // ),
        ],
      ),
    ));
  }
}
