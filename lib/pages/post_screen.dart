import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreen({
    this.postId,
    this.userId,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Scaffold(
          appBar: header(
            title: post.description,
            context: context,
            removeBackButton: false,
          ),
          body: ListView(
            children: [
              Container(
                child: post,
              )
            ],
          ),
        );
      },
    );
  }
}
