import 'package:client/functions/makeTransfer.dart';
import 'package:flutter/material.dart';
import '../functions/doQr.dart';  // Import the doQr function
import '../utils/account.dart'; // Import the Account class if needed
import '../functions/addTransaction.dart';
import '../functions/getAccountBalance.dart';

Future<void> showManualTransferDialog(BuildContext context, String accessToken, Account currentAccount) async {
  final accountNumberController = TextEditingController();
  final amountController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevents closing the dialog by tapping outside of it
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Manual Transfer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: accountNumberController,
                decoration: InputDecoration(labelText: 'Destination Account Number'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without making any changes
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final accountNumber = accountNumberController.text;
              final amount = double.tryParse(amountController.text) ?? 0.0;

              if (accountNumber.isEmpty || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid account number and a positive amount')),
                );
                return;
              }

              try {
                final success = await doQr(accessToken, currentAccount.numberAccount, accountNumber, amount);
                if (success) {
                  double balanceDestin = await getAccountBalance(accessToken, accountNumber);

                  await addTransaction(accessToken, currentAccount.numberAccount, "subtract", amount, currentAccount.balance);
                  await addTransaction(accessToken, accountNumber, "add", amount, balanceDestin);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transfer successful')),
                  );
                  // Close the dialog after the transfer
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to complete the transfer')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error completing the transfer: $e')),
                );
              }
            },
            child: Text('Transfer'),
          ),
        ],
      );
    },
  );
}
