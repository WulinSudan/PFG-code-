import 'package:flutter/material.dart';

Future<String?> getDescriptionDialog(BuildContext context) async {

  TextEditingController _controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter Description'),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Enter a description',
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without returning a value
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              final input = _controller.text;
              Navigator.of(context).pop(input.isNotEmpty ? input : null);
            },
          ),
        ],
      );
    },
  );
}
