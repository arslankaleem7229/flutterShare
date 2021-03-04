import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formkey = GlobalKey<FormState>();
  String username;

  submit(_scaffoldkey) {
    final form = _formkey.currentState;
    if (form.validate()) {
      form.save();

      _scaffoldkey.showSnackBar(SnackBar(content: Text('Welcome $username')));
      Timer(Duration(seconds: 3), () => Navigator.pop(context, username));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context: context, title: "Setup your profile"),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Create a Username',
              style: TextStyle(
                fontSize: 35.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
            child: Form(
              autovalidateMode: AutovalidateMode.always,
              key: _formkey,
              child: TextFormField(
                // ignore: missing_return
                validator: (validate) {
                  Pattern pattern = r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';
                  RegExp regex = new RegExp(pattern);

                  if (validate.trim().length < 3 || validate.isEmpty)
                    return 'Username is too short!';
                  else if (!regex.hasMatch(validate))
                    return 'Username is not Valid! ';
                  else
                    return null;
                },
                onSaved: (email) {
                  username = email;
                  print(username);
                },
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  hintText: 'Enter your username',
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: GestureDetector(
              onTap: () {
                submit(ScaffoldMessenger.of(context));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
                padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
