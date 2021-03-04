import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
bool isAuth = false;

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
    pageController.jumpToPage(
      pageIndex,
    );
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      print(account);
      setState(() {
        isAuth = true;
      });
    } else {
      print('Fucked Again : $isAuth');
      setState(() {
        isAuth = false;
      });
    }
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
            Upload(),
            Search(),
            Profile(),
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
        ));
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
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
              onTap: () {
                login();
              },
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
