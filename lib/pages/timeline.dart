import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';

class Timeline extends StatefulWidget {
  final User currentUser;
  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  int _postCount = 0;
  bool _isLoading = false;
  List<Post> timelineposts = [];
  bool _isEmpty = true;
  buildProfilePosts() {
    if (_isEmpty || _isLoading == true) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              "assets/images/no_content.svg",
              height: MediaQuery.of(context).size.height / 1.6,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'No Posts',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: timelineposts,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      _isLoading = true;
    });
    QuerySnapshot querySnapshot = await timelinePostsRef
        .doc(widget.currentUser?.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      _isLoading = false;

      _postCount = querySnapshot.docs.length;
      if (_postCount == 0) {
        _isEmpty = true;
      } else {
        _isEmpty = false;
      }
      timelineposts =
          querySnapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context: context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getProfilePosts(),
        child: ListView(
          children: [
            buildProfilePosts(),
          ],
        ),
      ),
    );
  }
}
