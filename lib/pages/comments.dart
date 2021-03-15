import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  Comments({this.postId, this.postMediaUrl, this.postOwnerId});
  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaUrl: this.postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  @override
  void dispose() {
    this.commentsController.dispose();

    super.dispose();
  }

  TextEditingController commentsController = TextEditingController();
  bool _isValid = true;
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  CommentsState({
    this.postId,
    this.postMediaUrl,
    this.postOwnerId,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context: context,
        isAppTitle: false,
        removeBackButton: false,
        title: "Comments",
      ),
      body: Column(
        children: [
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
            title: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Colors.greenAccent,
                  selectionColor: Colors.greenAccent,
                  selectionHandleColor: Colors.greenAccent,
                ),
              ),
              child: TextFormField(
                onChanged: (commentValue) {
                  if (commentValue.isNotEmpty) {
                    setState(() {
                      _isValid = true;
                    });
                  }
                },
                autofocus: false,
                controller: commentsController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: Colors.blue),
                  labelText: "Write a comment...",
                  errorText: _isValid ? null : "Write something...",
                ),
              ),
            ),
            trailing: OutlinedButton(
              onPressed: () {
                addComment();
              },
              style: ButtonStyle(
                side: MaterialStateProperty.all<BorderSide>(BorderSide.none),
              ),
              child: Text(
                "Post",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          )
        ],
      ),
    );
  }

  buildComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: commentRef
          .doc(postId)
          .collection("comments")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else if (snapshot.hasData) {
          List<Comment> comments = [];
          snapshot.data.docs.forEach((document) {
            comments.add(Comment.fromDocument(
              document,
              postId: postId,
              postOwnerId: postOwnerId,
            ));
          });
          return ListView(
            reverse: true,
            shrinkWrap: true,
            children: comments,
          );
        } else {
          return Text("null");
        }
      },
    );
  }

  addCommentsinActivityFeed(String commentsId) {
    print(commentsId);
    activityFeedRef
        .doc(postOwnerId)
        .collection('feedItems')
        .doc(commentsId)
        .set({
      "type": "comment",
      "commentData": commentsController.text,
      "username": currentUser.username,
      "userId": currentUser.id,
      "userProfileImg": currentUser.photoURL,
      "postId": postId,
      "mediaUrl": postMediaUrl,
      "timeStamp": DateTime.now(),
    });
  }

  addComment() async {
    String commentsId;
    bool isNotOwner = postOwnerId != currentUser.id;
    if (commentsController.text.isNotEmpty) {
      final commentsAdded = commentRef.doc(postId).collection("comments").add({
        "username": currentUser.username,
        "comment": commentsController.text,
        "timestamp": DateTime.now(),
        "avatarUrl": currentUser.photoURL,
        "userId": currentUser.id
      });
      await commentsAdded.then((value) {
        commentsId = value.id;
      });
      if (isNotOwner) {
        addCommentsinActivityFeed(commentsId);
      }
      _isValid = true;

      FocusScope.of(context).unfocus();
      commentsController.clear();
    } else if (commentsController.text.isEmpty) {
      _isValid = false;
    }
  }
}

class Comment extends StatefulWidget {
  final String postOwnerId;
  final String username;
  final String avatarUrl;
  final String userId;
  final Timestamp timestamp;
  final String comment;
  final String commentId;
  final String postId;
  Comment({
    this.postOwnerId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
    this.userId,
    this.username,
    this.commentId,
    this.postId,
  });

  factory Comment.fromDocument(DocumentSnapshot doc,
      {String postId, @required String postOwnerId}) {
    return Comment(
      postOwnerId: postOwnerId,
      avatarUrl: doc['avatarUrl'],
      comment: doc["comment"],
      timestamp: doc["timestamp"],
      userId: doc["userId"],
      username: doc['username'],
      commentId: doc.id,
      postId: postId,
    );
  }

  @override
  _CommentState createState() => _CommentState(
      postOwnerId: this.postOwnerId,
      avatarUrl: this.avatarUrl,
      comment: this.comment,
      commentId: this.commentId,
      postId: this.postId,
      timestamp: this.timestamp,
      userId: this.userId,
      username: this.username);
}

class _CommentState extends State<Comment> {
  String postOwnerId;
  String username;
  String avatarUrl;
  String userId;
  Timestamp timestamp;
  String comment;
  String commentId;
  String postId;
  _CommentState({
    this.postOwnerId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
    this.userId,
    this.username,
    this.commentId,
    this.postId,
  });

  TextEditingController updateCommentcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onLongPress: () {
            _settingModalBottomSheet(context,
                commentId: widget.commentId,
                postId: widget.postId,
                comment: widget.comment);
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.avatarUrl),
            ),
            title: Text(widget.comment),
            subtitle: Text(timeago.format(widget.timestamp.toDate())),
          ),
        ),
        Divider(),
      ],
    );
  }

  removeCommentsFromActivityFeed({String commentId}) {
    activityFeedRef
        .doc(postOwnerId)
        .collection("feedItems")
        .doc(commentId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  _settingModalBottomSheet(context,
      {String commentId, String postId, String comment}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
        context: context,
        builder: (context) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                    leading: Icon(
                      Icons.upload_rounded,
                      color: Colors.green,
                    ),
                    title: Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20.0))),
                        builder: (context) => updateComment(
                          context: context,
                          comment: comment,
                          commentId: commentId,
                          postId: postId,
                        ),
                      );
                    }),
                ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    commentRef
                        .doc(postId)
                        .collection("comments")
                        .doc(commentId)
                        .delete();
                    bool isNotOwner = postOwnerId != currentUser.id;
                    if (isNotOwner) {
                      removeCommentsFromActivityFeed(commentId: commentId);
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  updateCommentFromActivityFeed({String commentId}) {
    activityFeedRef
        .doc(postOwnerId)
        .collection("feedItems")
        .doc(commentId)
        .update({
      "commentData": updateCommentcontroller.text,
    });
  }

  updateComment(
      {BuildContext context, String comment, String commentId, String postId}) {
    bool isValid = true;
    updateCommentcontroller.text = comment;
    return Container(
      padding: EdgeInsets.all(40.0),
      child: ListView(
        children: [
          Wrap(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Update Comment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.green,
                  ),
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: Colors.green,
                    selectionColor: Colors.green,
                    selectionHandleColor: Colors.green,
                  ),
                ),
                child: TextField(
                  cursorWidth: 3.0,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green)),
                      // counterStyle: TextStyle(color: Colors.green),

                      errorText: isValid ? null : "Mendatory",
                      labelText: 'Update Comment',
                      labelStyle: TextStyle(color: Colors.green)),
                  autofocus: true,
                  textAlign: TextAlign.center,
                  controller: updateCommentcontroller,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          TextButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.greenAccent),
            ),
            child: Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (updateCommentcontroller.text.isNotEmpty) {
                setState(() {
                  isValid = true;
                });
                bool isNotOwner = postOwnerId != currentUser.id;
                commentRef
                    .doc(postId)
                    .collection("comments")
                    .doc(commentId)
                    .update({
                  "comment": updateCommentcontroller.text,
                });
                if (isNotOwner) {
                  updateCommentFromActivityFeed(commentId: commentId);
                }
                Navigator.pop(context);
              } else {
                setState(() {
                  isValid = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
