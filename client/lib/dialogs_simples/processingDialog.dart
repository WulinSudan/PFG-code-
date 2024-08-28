import 'package:flutter/material.dart';
import 'dart:async';

Future<void> processingDialog(BuildContext context, String text) async {
  // Show the dialog
  showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevents closing the dialog by tapping outside
    builder: (BuildContext context) {
      // Return the AlertDialog widget
      return AlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min, // Use min to ensure that the row doesn't take full width
          children: [
            Icon(Icons.hourglass_full, color: Colors.green), // Hourglass icon for processing
            SizedBox(width: 10), // Add some space between the icon and the text
            Text("Processing..."), // Text indicating that processing is happening
          ],
        ),
        content: Text(text), // Display the provided text
      );
    },
  );

  // Close the dialog after 3 seconds
  await Future.delayed(Duration(seconds: 5));
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}
