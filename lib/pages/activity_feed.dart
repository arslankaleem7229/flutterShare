import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/comments.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/post_screen.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  void dispose() {
    super.dispose();
  }

  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(currentUser.id)
        .collection("feedItems")
        .orderBy("timeStamp", descending: true)
        .limit(50)
        .get();

    List<ActivityFeedItem> activities = [];
    snapshot.docs.forEach((document) {
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
              }
              return ListView(
                // reverse: true,
                // shrinkWrap: true,
                children: snapshot.data,
              );
            },
          ),
        ));
  }
}

Widget _mediaPreview;
String _activityItemText;

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
      timestamp: doc["timeStamp"],
      userId: doc["userId"],
      username: doc['username'],
      mediaUrl: doc["mediaUrl"],
      commentId: doc.id,
      commentData: doc["commentData"],
    );
  }
  _showPost({@required context}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: userId,
        ),
      ),
    );
  }

  _configgureMediaPreview({@required context}) {
    if (type == 'like' || type == 'comment') {
      _mediaPreview = GestureDetector(
        onTap: () {
          _showPost(context: context);
        },
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
      _mediaPreview = Container(
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
      _activityItemText = "liked your post";
    } else if (type == 'comment') {
      _activityItemText = "commented: $commentData";
    } else if (type == 'follow') {
      _activityItemText = "is following you";
    } else {
      _activityItemText = "Error: Unknown type $type";
    }
  }

  @override
  Widget build(BuildContext context) {
    _configgureMediaPreview(context: context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          leading: GestureDetector(
            onTap: () => _showProfile(context, profileId: userId),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Comments(
                            postId: postId,
                            postMediaUrl: mediaUrl,
                            postOwnerId: userId,
                          )));
            },
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(fontSize: 14.0, color: Colors.black),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: " $_activityItemText",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: _mediaPreview,
        ),
      ),
    );
  }
}

_showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(profileId: profileId),
    ),
  );
}
