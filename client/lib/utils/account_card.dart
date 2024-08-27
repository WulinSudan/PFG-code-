import 'package:flutter/material.dart';
import 'account.dart';

class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Account ID: ${account.numberAccount}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ${account.balance}'),
            Text('Active: ${account.active}'),
            Text('Description: ${account.description}'),
          ],
        ),
      ),
    );
  }
}

Widget accountCard(Account account) {
  return AccountCard(account: account);
}
