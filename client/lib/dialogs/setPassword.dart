import 'package:flutter/material.dart';
import '../functions/setPassword.dart';  // Assuming the function is renamed to `setPassword`
import '../dialogs_simples/okDialog.dart';

Future<void> showSetPasswordDialog(BuildContext context, String accessToken, String dni) async {
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevents closing the dialog by tapping outside of it
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Set Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              final newPassword = newPasswordController.text;
              final confirmNewPassword = confirmNewPasswordController.text;

              if (newPassword != confirmNewPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              try {
                final success = await setPassword(accessToken, newPassword, dni);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password changed successfully')),
                  );

                  // Close the dialog
                  Navigator.of(context).pop();

                  // Show confirmation dialog
                  okDialog(context, "Password Changed Successfully");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to change password')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error changing password: $e')),
                );
              }
            },
            child: Text('Change'),
          ),
        ],
      );
    },
  );
}
