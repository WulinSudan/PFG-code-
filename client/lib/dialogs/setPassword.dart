import 'package:flutter/material.dart';
import '../functions/setPassword.dart';  // Assuming the function is renamed to `setPassword`
import '../dialogs_simples/okDialog.dart';
import '../dialogs_simples/errorDialog.dart';

Future<void> showSetPasswordDialog(BuildContext context, String accessToken, String dni) async {
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevents closing the dialog by tapping outside of it
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          void _validateFields() {
            setState(() {});
          }

          bool isPasswordValid = newPasswordController.text.length >= 3;
          bool doPasswordsMatch = newPasswordController.text == confirmNewPasswordController.text;

          return AlertDialog(
            title: Text('Set Password'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: isPasswordValid
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                    onChanged: (value) {
                      _validateFields();
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: confirmNewPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      suffixIcon: doPasswordsMatch
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                    onChanged: (value) {
                      _validateFields();
                    },
                  ),
                  SizedBox(height: 16),
                  // Validation messages
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
                onPressed: isPasswordValid && doPasswordsMatch ? () async {
                  final newPassword = newPasswordController.text;

                  try {
                    final success = await setPassword(accessToken, newPassword, dni);
                    if (success) {
                      Navigator.of(context).pop(); // Close the dialog
                      okDialog(context, "Password changed successfully");
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
                } : null,
                child: Text('Change'),
              ),
            ],
          );
        },
      );
    },
  );
}
