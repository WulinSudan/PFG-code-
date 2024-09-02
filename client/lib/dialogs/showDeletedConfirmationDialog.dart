import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/account.dart';
import '../functions/removeUserAccount.dart';
import 'selectAccountDialog.dart';


Future<void> showDeleteConfirmationDialog(BuildContext context, String accessToken, List<Account> accounts, Account selectedAccount, Future<void> Function() fetchData) async {
  if (selectedAccount.balance == 0) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this account?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();

                // Remove the account
                await removeAccount(context, accessToken, selectedAccount.numberAccount);
                await fetchData();
              },
            ),
          ],
        );
      },
    );
  } else {
    // Show a dialog to select another account or handle the case when balance is not zero
    selectAccountDialog(context, accessToken, accounts, selectedAccount, fetchData);

  }
}
