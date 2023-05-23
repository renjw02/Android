import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/resources/textpost_methods.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../resources/database_methods.dart' as db;

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
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('更换头像'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('拍照'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                    photos.add(file);
                    print(photos.length);
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('上传本地图片'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                    photos.add(file);
                    print(photos.length);
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

  buildTable(){
    int count = 0;
    if(photos==null){
      return Center(
        child: IconButton(
            icon: const Icon(
              Icons.add_photo_alternate,
            ),
            onPressed: ()async{
              await _selectImage(context);
              setState(() {});
            }
        ),
      );
    }
    List<Container> arow = [];
    for(var photo in photos){
      arow.add(
        Container(
          margin: const EdgeInsets.all(10.0), // 设置边距
          child: ListView(
            shrinkWrap: true,
            children:[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.12,
                width: MediaQuery.of(context).size.width*0.1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
                  child: Image.memory(photo,fit: BoxFit.fill),
                ),
              ),
            ]
          )
        ),
      );
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
        Center(
          child: IconButton(
              icon: const Icon(
                Icons.add_photo_alternate,
              ),
              onPressed: ()async{
                await _selectImage(context);
                setState(() {});
              }
          ),
        ),
        // Expanded(
        //     child:GridView.count(
        //   scrollDirection: Axis.vertical,
        //   crossAxisCount: 3,
        //   shrinkWrap: true,
        //   children: arow,
        // )),
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
      photos = [];
    });
  }
  
  void post() async {
    try{
      Map<String ,int> topic2type = {"校园资讯":1,"二手交易":2};
      if(photos == null){
        print("file is null");
      }
      List<Uint8List?> files = photos;
      print(topic2type[topicContent]!);
      Map<Color,String> colors = {Colors.red:"red",Colors.white:"white",Colors.yellow:"yellow"};
      Map<FontWeight,String> weights = {FontWeight.w300:"较细",FontWeight.w500:"适中",FontWeight.w700:"较粗"};
      String res = await db.DataBaseManager().createPost(titlec.text, contentc.text, topic2type[topicContent]!, "position",
          font_size,colors[font_color]!,weights[font_weight]!,photos);
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
            // Row(
            //   mainAxisAlignment:MainAxisAlignment.spaceBetween,
            //   children: [
            //     IconButton(
            //       icon: const Icon(
            //         Icons.topic,
            //       ),
            //       onPressed: () => _selectTopic(context),
            //     ),
            //     Text("${topicContent}"),
            //     // if (currentLocation != null)
            //     // Text("Location: ${currentLocation?.latitude}, ${currentLocation?.longitude}"),
            //     const Divider(),
            //     //if (currentLocation != null) Text("Address: $address"),
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.topic),
                  onPressed: () => _selectTopic(context),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: TextButton(
                      onPressed: () => _selectTopic(context) ,
                      child: Text(
                        topicContent,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    // do something on tap
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
                children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.33,
                  child: DropdownButton(
                    value: font_size, //style: style,
                    icon: Icon(Icons.arrow_drop_down), iconSize: 30, iconEnabledColor: Colors.deepPurple.withOpacity(0.7),
                    hint: Text('请选择地区'), isExpanded: true,
                    underline: Container(height: 1, color: Colors.deepPurple.withOpacity(0.7)),
                    items: [
                    DropdownMenuItem(
                    child: Row(children: <Widget>[Icon(Icons.text_fields, color: Colors.deepPurple),SizedBox(width: 20),
                      Text('小字体',style: TextStyle(fontSize: 12)), SizedBox(width: 5)]),
                    value: 12),
                    DropdownMenuItem(
                    child: Row(children: <Widget>[Icon(Icons.text_fields, color: Colors.deepPurple),SizedBox(width: 15),Text('适中',style: TextStyle(fontSize: 16)), SizedBox(width: 5)]),
                    value: 16),
                    DropdownMenuItem(
                    child: Row(children: <Widget>[Icon(Icons.text_fields, color: Colors.deepPurple),SizedBox(width: 5),Text('大字体', style: TextStyle(fontSize: 20)), SizedBox(width: 5)]),
                    value: 20)
                    ],
                    onChanged: (value) => setState(() => font_size = value!)
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.03),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.25,
                  child: DropdownButton(
                      value: font_color, //style: style,
                      icon: Icon(Icons.arrow_drop_down), iconSize: 30, iconEnabledColor: Colors.red.withOpacity(0.7),
                      hint: Text('请选择字体颜色'), isExpanded: true, underline: Container(height: 1, color: Colors.red.withOpacity(0.7)),
                      items: [
                        DropdownMenuItem(
                            child: Row(children: <Widget>[Icon(Icons.color_lens, color: Colors.red),
                              SizedBox(width: 5),Text('红色',style: TextStyle(color: Colors.red, fontSize: 16)), SizedBox(width: 5)]),
                            value: Colors.red),
                        DropdownMenuItem(
                            child: Row(children: <Widget>[Icon(Icons.color_lens, color: Colors.white),
                              SizedBox(width: 5),Text('白色',style: TextStyle(color: Colors.white, fontSize: 16)), SizedBox(width: 5)]),
                            value: Colors.white),
                        DropdownMenuItem(
                            child: Row(children: <Widget>[Icon(Icons.color_lens, color: Colors.yellow),
                              SizedBox(width: 5),Text('黄色', style: TextStyle(color: Colors.yellow, fontSize: 16)), SizedBox(width: 5)]),
                            value: Colors.yellow)
                      ],
                      onChanged: (value) => setState(() => font_color = value!)
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.03),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.25,
                  child: DropdownButton(
                      value: font_weight, //style: style,
                      icon: Icon(Icons.arrow_drop_down), iconSize: 30, iconEnabledColor: Colors.teal.withOpacity(0.7),
                      hint: Text('请选择字体粗细'), isExpanded: true, underline: Container(height: 1, color: Colors.teal.withOpacity(0.7)),
                      items: [
                        DropdownMenuItem(
                            child: Row(children: <Widget>[Icon(Icons.format_bold, color: Colors.teal),
                              SizedBox(width: 5),Text('较细', style: TextStyle(fontWeight: FontWeight.w300)), SizedBox(width: 5) ]),
                            value: FontWeight.w300),
                        DropdownMenuItem(
                            child: Row(children: <Widget>[Icon(Icons.format_bold, color: Colors.teal),
                              SizedBox(width: 5),
                              Text('适中', style: TextStyle(fontWeight: FontWeight.w500)), SizedBox(width: 5)]),
                            value: FontWeight.w500),
                        DropdownMenuItem(
                            child: Row(children: <Widget>[Icon(Icons.format_bold, color: Colors.teal),
                              SizedBox(width: 5),
                              Text('较粗', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(width: 5)]),
                            value: FontWeight.w700)
                      ],
                      onChanged: (value) => setState(() => font_weight = value!)
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
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: contentc,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "请输入内容",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(fontSize: 18),
                ),
              ),
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