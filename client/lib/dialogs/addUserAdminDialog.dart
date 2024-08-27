import 'package:flutter/material.dart';

Future<void> showAddUserAdminDialog(BuildContext context, String accessToken) async {
  bool isAdmin = false;
  bool optionSelected = false; // Variable to track if an option has been selected

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Select User Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAdmin = false;
                      optionSelected = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(
                      color: !isAdmin && optionSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text('Add User'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAdmin = true;
                      optionSelected = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(
                      color: isAdmin && optionSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text('Add Admin'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: optionSelected
                    ? () {
                  Navigator.of(context).pop(); // Close the dialog first

                  Navigator.pushNamed(
                    context,
                    isAdmin ? '/registrationAdmin' : '/registrationUser',
                    arguments: accessToken,
                  );
                }
                    : null, // Disable the button if no option has been selected
                child: Text('Add'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
  );
}
