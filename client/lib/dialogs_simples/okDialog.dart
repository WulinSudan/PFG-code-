import 'package:flutter/material.dart';
import 'dart:async';

Future<void> okDialog(BuildContext context, String text) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevents closing the dialog by tapping outside
    builder: (BuildContext context) {
      // Schedule the automatic closing of the dialog after 2 seconds
      Timer(Duration(seconds: 2), () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });

      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green), // Add a red error icon
            SizedBox(width: 10), // Add some space between the icon and the text
            Text('Correct'), // Corrected the title text
          ],
        ),
        content: Text(text), // Ensure the content is wrapped in a Text widget
      );
    },
  );
}
