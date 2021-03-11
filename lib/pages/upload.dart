import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
// ignore: unused_import
import 'package:fluttershare/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as IM;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  Position _currentPosition;
  String _currentAddress;
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  File imageFile;
  double heightofScreen;
  String postID = Uuid().v4();
  double widthofScreen;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future getImage(int type) async {
    PickedFile pickedImage = await ImagePicker().getImage(
        source: type == 1 ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 100,
        maxHeight: heightofScreen,
        maxWidth: widthofScreen);
    return pickedImage;
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress =
            "${place.locality}, ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  handleImagefromCamera() async {
    Navigator.pop(context);
    final tempfile = await getImage(1);
    print(tempfile);
    setState(() {
      imageFile = File(tempfile.path);
    });
  }

  handleImagefromGallery() async {
    Navigator.pop(context);
    final tempfile = await getImage(2);
    print(tempfile);

    setState(() {
      imageFile = File(tempfile.path);
    });
  }

  selectImage(parentcontext) {
    return showDialog(
        context: parentcontext,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Upload Image'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () => handleImagefromCamera(),
                child: const Text('Take an Image'),
              ),
              SimpleDialogOption(
                onPressed: () => handleImagefromGallery(),
                child: const Text('Choose from Gallery'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        });
  }

  Container buildSplashScreen(context) {
    heightofScreen = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    widthofScreen = MediaQuery.of(context).size.height;
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: heightofScreen / 2,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              child: Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: () {
                selectImage(context);
              },
            ),
          )
        ],
      ),
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    IM.Image tempImageFile = IM.decodeImage(imageFile.readAsBytesSync());
    final compressedImageFile = File('$tempPath/img_$postID.jpg')
      ..writeAsBytesSync(IM.encodeJpg(tempImageFile, quality: 85));
    setState(() {
      imageFile = compressedImageFile;
    });
  }

  clearImage() {
    setState(() {
      imageFile = null;
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    // ignore: unused_local_variable
    String mediaURL = await uploadImage(imageFile);
    createPostInFirestore(
      mediaURL: mediaURL,
      location: locationController.text,
      description: captionController.text,
    );
    locationController.clear();
    captionController.clear();
    setState(() {
      imageFile = null;
      postID = Uuid().v4();
      isUploading = false;
    });
  }

  createPostInFirestore(
      {@required String mediaURL, String description, String location}) {
    postRef.doc(widget.currentUser.id).collection("userPosts").doc(postID).set({
      "postId": postID,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaURL": mediaURL,
      "description": description,
      "location": location,
      "timestamp": timeStamp,
      "likes": {}
    });
  }

  Future<String> uploadImage(_imageFile) async {
    UploadTask uploadTask =
        storageReference.child('post_$postID.jpg').putFile(_imageFile);
    String downloadURL = await (await uploadTask).ref.getDownloadURL();
    return downloadURL;
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white70,
        actions: [
          FlatButton(
              onPressed: isUploading ? null : () => handleSubmit(),
              child: Text(
                'Post',
                style: TextStyle(color: Colors.blueAccent, fontSize: 20.0),
              )),
        ],
        leading: IconButton(
          onPressed: () {
            clearImage();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: [
          // isUploading ? linearProgress() : Text(""),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              height: heightofScreen * 0.3,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: FileImage(File(imageFile.path)), fit: BoxFit.cover),
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoURL),
            ),
            title: Container(
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: 'Write a Caption ... ',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              size: 40.0,
              color: Colors.orange,
            ),
            title: Container(
              child: TextField(
                controller: locationController,
                onChanged: (location) {},
                decoration: InputDecoration(
                  hintText: 'Current Location',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                icon: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    locationController.text = _currentAddress;
                  });
                },
                color: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                label: Text(
                  'User Current Location',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return imageFile == null ? buildSplashScreen(context) : buildUploadForm();
  }
}
