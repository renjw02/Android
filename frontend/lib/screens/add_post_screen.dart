import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/resources/textpost_methods.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/utils.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  String topicContent = "选择一个话题";
  LocationData? currentLocation;
  String address = "";
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _getLocation().then((value) {
      LocationData? location = value;
      _getAddress(location?.latitude, location?.longitude)
          .then((value) {
        setState(() {
          currentLocation = location;
          address = value;
        });
      });
    });
    print(address);
  }

  Future<LocationData?> _getLocation() async {
    Location location = new Location();
    LocationData _locationData;

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }


    _locationData = await location.getLocation();

    return _locationData;
  }

  Future<String> _getAddress(double? lat, double? lang) async {
    if (lat == null || lang == null) return "";
    GeoCode geoCode = GeoCode();
    Address address =
    await geoCode.reverseGeocoding(latitude: lat, longitude: lang);
    return "${address.streetAddress}, ${address.city}, ${address.countryName}, ${address.postal}";
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

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = 'unimplemented';
      // String res = await FireStoreMethods().uploadPost(
      //   _descriptionController.text,
      //   _file!,
      //   uid,
      //   username,
      //   profImage,
      // );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
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
                onPressed: null,
                // onPressed: () => postImage(
                //   userProvider.getUser.uid,
                //   userProvider.getUser.username,
                //   userProvider.getUser.photoUrl,
                // ),
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
            children: [
              IconButton(
                icon: const Icon(
                  Icons.topic,
                ),
                onPressed: () => _selectTopic(context),
              ),
              Text("${topicContent}"),
              if (currentLocation != null)
              Text("Location: ${currentLocation?.latitude}, ${currentLocation?.longitude}"),
              if (currentLocation != null) Text("Address: $address"),
            ],
          ),
          TextField(
              decoration: const InputDecoration(
                hintText: "如何评价",
                labelText: "内容",
                prefixIcon: Icon(Icons.content_copy),
              ),
              maxLines: null,
              minLines: 1,
          ),
          Center(
            child: IconButton(
              icon: const Icon(
                Icons.upload,
              ),
              onPressed: () => _selectImage(context),
            ),
          )
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
