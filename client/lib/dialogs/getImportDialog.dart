import 'package:flutter/material.dart';

Future<double?> getImportDialog(BuildContext context) async {
  print("In the getImportDialog function-----------");
  TextEditingController _controller = TextEditingController();

  return showDialog<double>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter Amount'),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter a number',
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
              // Return the entered amount converted to double
              final input = _controller.text;
              if (input.isNotEmpty) {
                Navigator.of(context).pop(double.tryParse(input));
              } else {
                Navigator.of(context).pop(); // Close the dialog without returning a value
              }
            },
          ),
        ],
      );
    },
  );
}
