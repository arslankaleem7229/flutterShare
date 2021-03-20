import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
// ignore: unused_import
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final userRef = FirebaseFirestore.instance.collection('users');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final postRef = FirebaseFirestore.instance.collection('posts');
final timelinePostsRef = FirebaseFirestore.instance.collection('timeline');
final commentRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feeds');

final Reference storageReference = FirebaseStorage.instance.ref();
final GoogleSignIn googleSignIn = GoogleSignIn();
bool isAuth = false;
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController pageController;

  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signingIn : $err');
    });
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error SigninIn : $err');
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  changePageIndex(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();

      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    //1). Check if user exists in users collection in database (according to their id).

    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot document = await userRef.doc(user.id).get();

    //2). if the user doesn't exist, then we want to take them to the create account page.
    if (!document.exists) {
      final username = user.email.substring(0, user.email.indexOf('@'));

      //3). get username from create account user it to make new user document in users collection

      userRef.doc(user.id).set({
        "id": user.id,
        "email": user.email,
        "photoURL": user.photoUrl,
        "displayname": user.displayName,
        "username": username,
        "bio": "N/A",
        "timestamp": DateTime.now(),
      });
      document = await userRef.doc(user.id).get();
    }
    currentUser = User.fromDocument(document);
    // print(currentUser);
    // print(currentUser.email.substring(0, user.email.indexOf('@')));
  }

  BottomNavigationBarItem bottomNavigationBarItem(Icon icon) {
    return BottomNavigationBarItem(icon: icon);
  }

  Widget buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: [
          Timeline(),
          ActivityFeed(),
          Upload(
            currentUser: currentUser,
          ),
          Search(),
          Profile(
            profileId: currentUser?.id,
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        // physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: changePageIndex,
        activeColor: Theme.of(context).primaryColor,
        items: [
          bottomNavigationBarItem(Icon(Icons.whatshot)),
          bottomNavigationBarItem(Icon(Icons.notifications)),
          bottomNavigationBarItem(Icon(Icons.photo_camera, size: 35.0)),
          bottomNavigationBarItem(Icon(Icons.search)),
          bottomNavigationBarItem(Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                'FlutterShare',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Signatra',
                  fontSize: 90.0,
                ),
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
