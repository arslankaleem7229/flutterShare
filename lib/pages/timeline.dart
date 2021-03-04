import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

final users = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> userData = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(context: context, isAppTitle: true),
        body: FutureBuilder(
          future: users.get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            final List<Text> childrens =
                snapshot.data.docs.map((doc) => Text(doc['username'])).toList();
            return Container(
              child: ListView(
                children: childrens,
              ),
            );
          },
        ));
  }
}
