import 'package:flutter/material.dart';

Future<void> showWarningDialog(BuildContext context, String message) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context).pop(true);
      });

      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text('Advertencia'),
          ],
        ),
        content: Text(message),
      );
    },
  );
}
