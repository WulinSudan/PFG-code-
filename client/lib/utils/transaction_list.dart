import 'package:flutter/material.dart';
import 'transaction.dart'; // Asegúrate de importar tu modelo de transacción
import 'transaction_card.dart'; // Asegúrate de importar la tarjeta de transacción

class TransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final double currentBalance; // Añadido: importe actual de la cuenta

  const TransactionsList({
    Key? key,
    required this.transactions,
    required this.currentBalance, // Asegúrate de añadir esto
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionCard(
          transaction: transaction,
          currentBalance: currentBalance, // Pasar el saldo actual
        );
      },
    );
  }
}
