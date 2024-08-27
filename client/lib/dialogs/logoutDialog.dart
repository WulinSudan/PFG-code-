import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without any further action
            },
          ),
          TextButton(
            child: Text('Log Out'),
            onPressed: () async {
              // Remove the token from SharedPreferences
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('access_token');

              // Close the dialog
              Navigator.of(context).pop();

              // Redirect the user to the login page
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      );
    },
  );
}
