import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize FlutterFire
    Firebase.initializeApp();

    // Once complete, show your application
    return MaterialApp(
      title: 'FlutterShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Colors.teal,
        primarySwatch: Colors.purple,
      ),
      home: Home(),
    );
  }
}
