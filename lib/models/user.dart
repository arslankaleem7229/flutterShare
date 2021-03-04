import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final String photoURL;
  final String bio;
  final String username;

  User({
    this.id,
    this.username,
    this.bio,
    this.displayName,
    this.email,
    this.photoURL,
  });
  factory User.fromDocument(DocumentSnapshot document) {
    return User(
      id: document.data()['id'],
      displayName: document.data()['displayname'],
      username: document.data()['username'],
      email: document.data()['email'],
      bio: document.data()['bio'],
      photoURL: document.data()['photoURL'],
    );
  }
}
