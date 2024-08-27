import 'package:flutter/material.dart';
import 'dart:async';

Future<void> changeUserStatusDialog(BuildContext context, String name, bool status) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevents the dialog from closing when tapping outside of it
    builder: (BuildContext context) {
      // Schedule the dialog to close automatically after 2 seconds
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });

      return AlertDialog(
        title: Text('Confirmation'),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'User ',
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
              TextSpan(
                text: name,
                style: TextStyle(color: Colors.black87, fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ' is currently ',
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
              TextSpan(
                text: status ? 'active' : 'inactive',
                style: TextStyle(color: status ? Colors.green[700] : Colors.red[700], fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '.',
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
    },
  );
}
