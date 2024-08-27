import 'package:client/dialogs_simples/errorDialog.dart';
import 'package:flutter/material.dart';
import 'package:client/functions/changePassword.dart';
import 'package:client/dialogs_simples/okDialog.dart';

Future<void> showChangePasswordDialog(BuildContext context, String accessToken) async {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevent the dialog from closing when tapping outside of it
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Old Password'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: confirmNewPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without making changes
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldPassword = oldPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmNewPassword = confirmNewPasswordController.text;

              if (newPassword != confirmNewPassword) {
                errorDialog(context, "Passwords do not match");
                return;
              }

              try {
                final success = await changePassword(accessToken, oldPassword, newPassword);
                if (success) {
                  okDialog(context, "Password Changed Successfully");
                  Navigator.of(context).pop(); // Close the dialog
                  // Redirect to the login page
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login', // Route name for the login page
                        (Route<dynamic> route) => false, // Remove all previous routes
                  );
                } else {
                  errorDialog(context, "Failed to change password");
                }
              } catch (e) {
                errorDialog(context, "Failed to change password");
              }
            },
            child: Text('Change'),
          ),
        ],
      );
    },
  );
}
