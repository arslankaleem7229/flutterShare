import 'package:flutter/material.dart';

AppBar header(
    {BuildContext context,
    String title,
    double size,
    String family,
    bool isAppTitle = false,
    bool removeBackButton = true}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? 'FlutterShare' : title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: isAppTitle ? 50.0 : size,
        fontFamily: isAppTitle ? 'Signatra' : family,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
