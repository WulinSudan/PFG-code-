import 'package:flutter/material.dart';
import 'transaction.dart'; // Asegúrate de importar tu modelo de transacción

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final double? currentBalance; // Asegúrate de que currentBalance sea opcional

  const TransactionCard({Key? key, required this.transaction, this.currentBalance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determina el icono y el color basado en el tipo de operación
    final IconData iconData;
    final Color color;

    if (transaction.operation == "add") {
      iconData = Icons.payment; // Icono para importes positivos
      color = Colors.green;
    } else {
      iconData = Icons.remove; // Icono para importes negativos
      color = Colors.red;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              iconData,
              color: color,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.0),
                  Text(
                    '${transaction.import >= 0 ? '+' : ''}${transaction.import.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    transaction.getFormattedDate(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (currentBalance != null) ...[
              SizedBox(width: 16),
              Text(
                'Saldo: ${currentBalance!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
