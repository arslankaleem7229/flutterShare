import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print('Error during firestore');
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
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

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          title: 'FlutterShare',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            accentColor: Colors.teal,
            primarySwatch: Colors.purple,
          ),
          home: Home(),
        );
      },
    );
  }
}
