import 'package:flutter/material.dart';
import 'account.dart';

class AccountCard2 extends StatelessWidget {
  final Account account;

  const AccountCard2({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Cuenta ID: ${account.numberAccount}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo: ${account.balance}'),
            Text('max pay: ${account.maxPay}'),
            Text('Activa: ${account.active}'),
            Text('max pay day: ${account.maxPayDay}'),
          ],
        ),
      ),
    );
  }
}

Widget accountCard(Account account) {
  return AccountCard2(account: account);
}
