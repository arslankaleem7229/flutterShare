import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({@required this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _isdisable = true;
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool isLoading = false;
  bool _isBioValid = true;
  bool _isDisplayNameValid = true;

  User user;
  @override
  void initState() {
    super.initState();
    getUser();
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot documentSnapshot =
        await userRef.doc(widget.currentUserId).get();
    user = User.fromDocument(documentSnapshot);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  buildTextField(
      {@required String text,
      @required String hintText,
      @required TextEditingController textEditingController}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            text,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: textEditingController,
          decoration: InputDecoration(
            hintText: hintText,
          ),
        ),
      ],
    );
  }

  Column buildDisplayNameTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Display Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _isDisplayNameValid ? null : "Display Name is Invalid!",
          ),
        ),
      ],
    );
  }

  Column buildBioTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _isDisplayNameValid ? null : "Bio is Invalid!",
          ),
        ),
      ],
    );
  }

  updateProfile() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _isDisplayNameValid = false
          : _isDisplayNameValid = true;
      bioController.text.trim().length > 100
          ? _isBioValid = false
          : _isBioValid = true;
    });
    if (_isDisplayNameValid && _isBioValid) {
      userRef.doc(widget.currentUserId).update({
        "displayname": displayNameController.text,
        "bio": bioController.text,
      }).then((value) {
        setState(() {
          _isdisable = false;
        });
        SnackBar snackBar = SnackBar(content: Text('Profile Updated'));
        // ignore: deprecated_member_use
        _scaffoldkey.currentState.showSnackBar(snackBar);
        Navigator.pop(context);
      }).catchError((onError) => print(onError));
    }

    // _scaffoldkey
    //     .showSnackBar(SnackBar(content: Text('Profile Updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done,
              color: Colors.green,
              size: 30.0,
            ),
            onPressed: () => _isdisable ? null : Navigator.pop(context),
          )
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            user.photoURL,
                          ),
                          radius: 50.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            buildDisplayNameTextField(),
                            buildBioTextField(),

                            // buildTextField(
                            //   text: "Display Name",
                            //   hintText: "Update Display Name",
                            //   textEditingController: displayNameController,
                            // ),
                            // buildTextField(
                            //   text: "Bio",
                            //   hintText: "Update your Bio",
                            //   textEditingController: bioController,
                            // ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed))
                                return Colors.green;
                              return null; // Use the component's default.
                            },
                          ),
                        ),
                        onPressed: updateProfile,
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
                            // color: Theme.of(context).primaryColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: TextButton.icon(
                          onPressed: logout,
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                            // size: 35.0,
                          ),
                          label: Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
