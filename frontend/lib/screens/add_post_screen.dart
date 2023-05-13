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

import '../resources/database_methods.dart' as db;

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
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
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


  void clearImage() {
    setState(() {
      _file = null;
    });
  }
  
  void post(){
    Map<String ,int> topic2type = {"校园资讯":1,"二手交易":2};
    if(_file == null){
      print("file is null");
    }
    List<Uint8List?> files = [_file];
    print(topic2type[topicContent]!);
    print(files);
    db.DataBaseManager().createPost(titlec.text, contentc.text, topic2type[topicContent]!, "position", files);
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
          appBar: AppBar(
            backgroundColor: mobileBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: clearImage,
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
      body:Column(
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
          _file == null?
          Center(
            child: IconButton(
              icon: const Icon(
                Icons.upload,
              ),
              onPressed: () => _selectImage(context),
            ),
          ):SizedBox(
            height: 45.0,
            width: 45.0,
            child: AspectRatio(
              aspectRatio: 487 / 451,
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      alignment: FractionalOffset.topCenter,
                      image: MemoryImage(_file!),
                    )),
              ),
            ),
          ),
        ],
      ),
    );

    //   _file == null
    //     ? Center(
    //   child: IconButton(
    //     icon: const Icon(
    //       Icons.upload,
    //     ),
    //     onPressed: () => _selectImage(context),
    //   ),
    // )
    //     : Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: mobileBackgroundColor,
    //     leading: IconButton(
    //       icon: const Icon(Icons.arrow_back),
    //       onPressed: clearImage,
    //     ),
    //     title: const Text(
    //       'Post to',
    //     ),
    //     centerTitle: false,
    //     actions: <Widget>[
    //       TextButton(
    //         onPressed: () => postImage(
    //           userProvider.getUser.uid,
    //           userProvider.getUser.username,
    //           userProvider.getUser.photoUrl,
    //         ),
    //         child: const Text(
    //           "Post",
    //           style: TextStyle(
    //               color: Colors.blueAccent,
    //               fontWeight: FontWeight.bold,
    //               fontSize: 16.0),
    //         ),
    //       )
    //     ],
    //   ),
    //   // POST FORM
    //   body: Column(
    //     children: <Widget>[
    //       isLoading
    //           ? const LinearProgressIndicator()
    //           : const Padding(padding: EdgeInsets.only(top: 0.0)),
    //       const Divider(),
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: <Widget>[
    //           CircleAvatar(
    //             backgroundImage: NetworkImage(
    //               userProvider.getUser.photoUrl,
    //             ),
    //           ),
    //           SizedBox(
    //             width: MediaQuery.of(context).size.width * 0.3,
    //             child: TextField(
    //               controller: _descriptionController,
    //               decoration: const InputDecoration(
    //                   hintText: "Write a caption...",
    //                   border: InputBorder.none),
    //               maxLines: 8,
    //             ),
    //           ),
    //           SizedBox(
    //             height: 45.0,
    //             width: 45.0,
    //             child: AspectRatio(
    //               aspectRatio: 487 / 451,
    //               child: Container(
    //                 decoration: BoxDecoration(
    //                     image: DecorationImage(
    //                       fit: BoxFit.fill,
    //                       alignment: FractionalOffset.topCenter,
    //                       image: MemoryImage(_file!),
    //                     )),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //       const Divider(),
    //     ],
    //   ),
    // );
  }
}
