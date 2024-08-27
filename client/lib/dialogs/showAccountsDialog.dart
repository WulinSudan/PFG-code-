import 'package:flutter/material.dart';
import '../utils/account.dart'; // Make sure this is the correct name of the Account class file
import '../functions/getAccounts.dart'; // Make sure to import the getAccounts function
import '../utils/account_card_admin.dart'; // Make sure this is the correct name of the AccountCardAdmin class file
import '../functions/changeAccountStatus.dart'; // Make sure to import the changeAccountStatus function

Future<void> showAccountsDialog(BuildContext context, String accessToken, String dni) async {
  List<Account> accounts = [];
  Account? selectedAccount;

  try {
    accounts = await getAccounts(accessToken, dni); // Fetch the accounts here
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error fetching accounts: ${e.toString()}'),
      ),
    );
    return;
  }

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('User Accounts'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: accounts.map((account) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAccount = account;
                      });
                    },
                    child: AccountCardAdmin(
                      account: account,
                      isSelected: selectedAccount == account,
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              if (selectedAccount != null)
                TextButton(
                  child: Text('Change Status'),
                  onPressed: () async {
                    try {
                      bool success = await changeAccountStatus(accessToken, selectedAccount!.numberAccount);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Account ${selectedAccount!.numberAccount} deactivated.'),
                          ),
                        );
                        // Wait for 2 seconds before closing the dialog
                        await Future.delayed(Duration(seconds: 2));
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to deactivate the account.'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deactivating the account: ${e.toString()}'),
                        ),
                      );
                    }
                  },
                ),
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}
