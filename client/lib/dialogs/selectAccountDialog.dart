import 'package:client/dialogs_simples/errorDialog.dart';
import 'package:client/functions/removeUserAccount.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/account.dart';
import '../functions/makeTransfer.dart'; // Fixed typo from maketransfer to makeTransfer
import '../functions/addTransaction.dart';

Future<void> selectAccountDialog(BuildContext context, String accessToken, List<Account> accounts, Account currentAccount, Future<void> Function() fetchData) async {

  // Filter accounts excluding the current account
  List<Account> filteredAccounts = accounts.where((account) => account.numberAccount != currentAccount.numberAccount).toList();

  // Variable to store the selected account
  Account? selectedAccount;

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Empty the balance'),
            content: SingleChildScrollView(
              child: ListBody(
                children: filteredAccounts.map((account) {
                  return ListTile(
                    title: Text('${account.numberAccount} - Balance: ${account.balance.toStringAsFixed(2)}'),
                    tileColor: selectedAccount == account ? Colors.blue.withOpacity(0.5) : null,
                    onTap: () {
                      setState(() {
                        selectedAccount = account;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Accept'),
                onPressed: selectedAccount != null
                    ? () async {
                  if (selectedAccount != null) {

                    // Perform the transfer between the accounts
                    print("Llegado en aqui----------seleccionat un compte------------?");

                    bool transfer = await makeTransfer(context, accessToken, currentAccount, selectedAccount!);

                    if(transfer){
                      // Add a transaction for the current account
                      await addTransaction(
                          accessToken,
                          selectedAccount!.numberAccount,
                          "add", // Operation type
                          currentAccount.balance,
                          currentAccount.balance + selectedAccount!.balance // New balance after transfer
                      );
                      await fetchData();
                      removeAccount(context, accessToken, selectedAccount!.numberAccount);
                    }
                    else{
                      errorDialog(context, "Fail make transfer");
                    }


                  }
                  Navigator.of(context).pop(); // Close the dialog
                }
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: selectedAccount != null ? Colors.blue : Colors.grey, // Set text color based on selection
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
