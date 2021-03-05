import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:image_picker/image_picker.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  PickedFile imageFile;
  double heightofScreen;
  double widthofScreen;
  bool isUploading = false;

  Future getImage(int type) async {
    PickedFile pickedImage = await ImagePicker().getImage(
        source: type == 1 ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 100,
        maxHeight: heightofScreen,
        maxWidth: widthofScreen);
    return pickedImage;
  }

  handleImagefromCamera() async {
    Navigator.pop(context);
    final tempfile = await getImage(1);
    print(tempfile);
    setState(() {
      imageFile = tempfile;
    });
  }

  handleImagefromGallery() async {
    Navigator.pop(context);
    final tempfile = await getImage(2);
    print(tempfile);

    setState(() {
      imageFile = tempfile;
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

  clearImage() {
    setState(() {
      imageFile = null;
    });
  }

  handleSubmit() {
    setState(() {
      isUploading = true;
    });
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
                onPressed: () {},
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
