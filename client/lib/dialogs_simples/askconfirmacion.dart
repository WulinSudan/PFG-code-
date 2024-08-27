import 'package:flutter/material.dart';

Future<bool?> askConfirmation(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to proceed with this operation?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Returns 'false' if canceled
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Returns 'true' if accepted
            },
            child: Text('Accept'),
          ),
        ],
      );
    },
  );
}
