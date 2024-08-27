import 'package:flutter/material.dart';
import 'account.dart';

class AccountCardAdmin extends StatelessWidget {
  final Account account;
  final bool isSelected;

  const AccountCardAdmin({
    Key? key,
    required this.account,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey, // Bordes azules si está seleccionado
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: ListTile(
        title: Text('Cuenta ID: ${account.numberAccount}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo: ${account.balance}'),
            Text('Activa: ${account.active}'),
          ],
        ),
      ),
    );
  }
}
