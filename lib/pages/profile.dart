import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/edit_profile.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';

class Profile extends StatefulWidget {
  final profileId;
  Profile({@required this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void dispose() {
    super.dispose();
  }

  bool _isfollowing;

  bool _isEmpty = true;
  String _postOrientation = "Grid";
  List<Post> posts = [];
  bool _isLoading = false;
  int _postCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;
  User user;
  final String currentUserId = currentUser?.id;

  buildCountColumn({@required String label, @required int count}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
          ),
        )
      ],
    );
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(
          currentUserId: currentUserId,
        ),
      ),
    ).then((value) {
      setState(() {});
    });
  }

  buildButton({@required String text, @required Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: TextButton(
        onPressed: function,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.65,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: _isfollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isfollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: _isfollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  handleUnfollowUser() async {
    setState(() {
      _isfollowing = false;
    });
    // upload your id in user followers
    await followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .doc(currentUserId)
        .delete();

    //update you following by adding user to your following
    await followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .delete();
    //add activity feed item to notify user about new follower
    await activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .delete();
    QuerySnapshot gettingPosts = await postRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();

    gettingPosts.docs.forEach((post) {
      timelinePostsRef
          .doc(currentUserId)
          .collection('timelinePosts')
          .doc(post.id)
          .delete();
    });

    setState(() {
      getFollower();
      getFollowing();
    });
  }

  handleFollowUser() async {
    setState(() {
      _isfollowing = true;
    });
    // upload your id in user followers
    await followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .doc(currentUserId)
        .set({});
    //update you following by adding user to your following
    await followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    //add activity feed item to notify user about new follower
    await activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set(
      {
        "postId": null,
        "userProfileImg": currentUser.photoURL,
        "ownerId": widget.profileId,
        "type": "follow",
        "timeStamp": DateTime.now(),
        "userId": currentUserId,
        "username": currentUser.username,
        "mediaUrl": null,
        "commentData": null,
      },
    );

    QuerySnapshot gettingPosts = await postRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();

    gettingPosts.docs.forEach((post) {
      timelinePostsRef
          .doc(currentUserId)
          .collection('timelinePosts')
          .doc(post.id)
          .set(post.data());
    });

    setState(() {
      getFollower();
      getFollowing();
    });
  }

  buildPerformButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    } else if (_isfollowing) {
      print(_isfollowing);
      return buildButton(text: "Unfollow", function: handleUnfollowUser);
    } else {
      print(_isfollowing);

      return buildButton(text: "Follow", function: handleFollowUser);
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
        future: userRef.doc(widget.profileId).get(),
        builder: (context, snapshots) {
          if (!snapshots.hasData) {
            return circularProgress();
          } else {
            user = User.fromDocument(snapshots.data);

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: MediaQuery.of(context).size.width * 0.1,
                        backgroundImage: CachedNetworkImageProvider(
                          user.photoURL,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildCountColumn(
                                    label: "posts", count: _postCount),
                                buildCountColumn(
                                    label: "followers", count: _followerCount),
                                buildCountColumn(
                                    label: "following", count: _followingCount),
                              ],
                            ),
                            Row(
                              // crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildPerformButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      user.displayName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      user.username,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      user.bio,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollower();
    getFollowing();
    checkIffollowing();
  }

  bool equalsIgnoreCase(String string1, String string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  buildProfilePosts() {
    if (_isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              "assets/images/no_content.svg",
              height: MediaQuery.of(context).size.height / 2.5,
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
            )
          ],
        ),
      );
    } else {
      if (_isLoading == true) {
        return circularProgress();
      } else if (equalsIgnoreCase(_postOrientation, "Grid")) {
        List<GridTile> gridTiles = [];
        posts.forEach((post) {
          gridTiles.add(GridTile(child: PostTile(post)));
        });
        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: gridTiles,
        );
      } else {
        return Column(
          children: posts,
        );
      }
    }
  }

  getProfilePosts() async {
    setState(() {
      _isLoading = true;
    });
    QuerySnapshot querySnapshot = await postRef
        .doc(widget.profileId)
        .collection('userPosts')
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
      posts = querySnapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context: context,
        isAppTitle: false,
        title: 'Profile',
      ),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(height: 0.0),
          buildTogglePostOrientation(),
          Divider(height: 0.0),
          buildProfilePosts(),
        ],
      ),
    );
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.grid_on_rounded,
            size: 30.0,
            color: _postOrientation == "Grid"
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _postOrientation = "Grid";
            });
          },
        ),
        IconButton(
          icon: Icon(
            Icons.list,
            size: 30.0,
            color: _postOrientation != "Grid"
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _postOrientation = "List";
            });
          },
        ),
      ],
    );
  }

  checkIffollowing() async {
    DocumentSnapshot _documentSnapshot = await followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get();
    setState(() {
      _isfollowing = _documentSnapshot.exists;
    });
  }

  getFollowing() async {
    final following = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      _followingCount = following.docs.length;
    });
  }

  getFollower() async {
    final follow = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      _followerCount = follow.docs.length;
    });
  }
}
