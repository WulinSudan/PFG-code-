import 'package:flutter/material.dart';
import 'package:client/dialogs_simples/okDialog.dart';
import 'package:client/dialogs_simples/errorDialog.dart';
import 'package:client/functions/changeUserStatus.dart';
import 'package:client/functions/getUserStatusDni.dart'; // Import the function to get the user status

// Function to show a dialog with the user's status and confirm the change
Future<void> showUserStatusDialog(
    BuildContext context,
    String accessToken,
    String? dni,
    Future<void> Function() fetchData,
    ) async {
  if (dni != null) {
    try {
      // Fetch the current user status
      bool userStatus = await getUserStatusDni(accessToken, dni);

      // Show the dialog with the current user status and an option to confirm the change
      bool? confirmChange = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('User Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display the current status of the user
              Text(userStatus ? 'User is currently enabled.' : 'User is currently disabled.'),
              SizedBox(height: 16.0), // Space between text and buttons
              Text('Do you want to change the status?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancel
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Confirm
              child: Text('Change Status'),
            ),
          ],
        ),
      );

      // If the user confirms, change the status
      if (confirmChange == true) {
        await handleChangeUserStatus(context, accessToken, dni, fetchData);
      }

    } catch (e) {
      // Handle errors in fetching the user status
      errorDialog(context, "Error getting user status");
    }
  } else {
    // Handle the case where DNI is not provided
    errorDialog(context, "DNI is missing");
  }
}

// Function to change the user's status
Future<void> handleChangeUserStatus(
    BuildContext context,
    String accessToken,
    String? dni,
    Future<void> Function() fetchData,
    ) async {
  if (dni != null) {
    try {
      // Change the user status
      bool status = await changeUserStatus(accessToken, dni);
      if (status) {
        // Show success dialog with the new status
        okDialog(context, "User status is: Enabled");
      } else {
        // Show success dialog with the new status
        okDialog(context, "User status is: Disabled");
      }
    } catch (e) {
      // Handle errors in changing the user status
      errorDialog(context, "Error changing user status");
    }
    // Ensure the data is updated after changing the status
    await fetchData();
  } else {
    // Handle the case where DNI is not provided
    errorDialog(context, "DNI is missing");
  }
}
