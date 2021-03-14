import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(currentUser.id)
        .collection("feedItems")
        .orderBy("timeStamp", descending: false)
        .limit(50)
        .get();

    List<ActivityFeedItem> activities = [];
    snapshot.docs.forEach((document) {
      print(document.data());
      activities.add(ActivityFeedItem.fromDocument(document));
    });
    return activities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange[600],
        appBar: header(
            context: context, removeBackButton: true, title: "Activity Feed"),
        body: Container(
          child: FutureBuilder(
            future: getActivityFeed(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                print(snapshot.data);
                return ListView(
                  reverse: true,
                  shrinkWrap: true,
                  children: snapshot.data,
                );
              }
            },
          ),
        ));
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String postId;
  final String username;
  final String type;
  final String mediaUrl;
  final String userProfileImg;
  final String userId;
  final Timestamp timestamp;
  final String commentData;
  final String commentId;
  ActivityFeedItem({
    this.mediaUrl,
    this.type,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
    this.userId,
    this.username,
    this.commentId,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      postId: doc["postId"],
      userProfileImg: doc["userProfileImg"],
      type: doc["type"],
      timestamp: doc["timestamp"],
      userId: doc["userId"],
      username: doc['username'],
      commentId: doc.id,
      commentData: doc["commentData"],
    );
  }
  configgureMediaPreview() {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => print("Showing Post"),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Container(
        height: 50.0,
        width: 50.0,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/no_image.png"),
              ),
            ),
          ),
        ),
      );
    }
    if (type == 'like') {
      activityItemText = "liked your post";
    } else if (type == 'comment') {
      activityItemText = "commented: $commentData";
    } else if (type == 'follow') {
      activityItemText = "is following you";
    } else {
      activityItemText = "Error: Unknown type $type";
    }
  }

  @override
  Widget build(BuildContext context) {
    configgureMediaPreview();

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          title: GestureDetector(
            onTap: () => print("show Profile"),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(style: TextStyle(fontSize:14.0)),
            ),
          ),
        ),
      ),
    );
  }
}
