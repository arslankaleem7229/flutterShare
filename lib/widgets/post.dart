import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/comments.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });
  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot['postId'],
      ownerId: documentSnapshot['ownerId'],
      username: documentSnapshot['username'],
      location: documentSnapshot['location'],
      description: documentSnapshot['description'],
      mediaUrl: documentSnapshot['mediaURL'],
      likes: documentSnapshot['likes'],
    );
  }

  int getLikeCount({likes}) {
    int count = 0;
    // if no likes, return or zero
    if (likes == null) {
      return 0;
    } else {
      //if the key is explicitly set to true, add +1 to like
      likes.values.forEach((val) {
        if (val == true) {
          count += 1;
        }
      });
    }
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        description: this.description,
        likes: this.likes,
        location: this.location,
        mediaUrl: this.mediaUrl,
        username: this.username,
        likeCount: getLikeCount(likes: this.likes),
      );
}

class _PostState extends State<Post> {
  final String _currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;
  bool isLiked;
  bool showHeart = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likeCount,
    this.likes,
  });
  @override
  Widget build(BuildContext context) {
    isLiked = (likes[_currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }

  buildPostHeader() {
    return FutureBuilder(
      future: userRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          User user = User.fromDocument(snapshot.data);
          return ListTile(
            leading: CircleAvatar(
              radius: 23.0,
              backgroundImage: CachedNetworkImageProvider("${user.photoURL}"),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => print("Showing Profile"),
              child: Text(
                this.username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text(location),
            trailing: IconButton(
              onPressed: () => print("Post Option"),
              icon: Icon(Icons.more_vert),
            ),
          );
        }
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {
        handleLikePost();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(mediaUrl),
          showHeart
              ? Animator(
                  tween: Tween(begin: 0.8, end: 1.4),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (context, anim, child) => Transform.scale(
                    scale: anim.value,
                    child: Icon(
                      Icons.favorite,
                      size: 80.0,
                      color: Colors.red,
                    ),
                  ),
                )
              : Text(""),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () {
                if (isLiked == true) {
                  handleLikePost();
                } else {
                  handleLikePost();
                }
              },
              child: Icon(
                isLiked == true ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Comments(
                        postId: postId,
                        postOwnerId: ownerId,
                        postMediaUrl: mediaUrl,
                      ),
                    ));
              },
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(description),
            ),
          ],
        )
      ],
    );
  }

  addLikestoActivityFeed() {
    bool isNotPostOwner = _currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef.doc(ownerId).collection('feedItems').doc(postId).set({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoURL,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timeStamp": DateTime.now(),
      });
    }
  }

  removeLikesFromActivityFeed() {
    bool isNotPostOwner = _currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection('feedItems')
          .doc(postId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  handleLikePost() {
    bool _isLiked = likes[_currentUserId] == true;

    if (_isLiked) {
      postRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$_currentUserId': false});
      removeLikesFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[_currentUserId] = false;
      });
    } else if (!_isLiked) {
      postRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$_currentUserId': true});
      addLikestoActivityFeed();

      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[_currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }
}
