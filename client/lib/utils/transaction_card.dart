import 'package:flutter/material.dart';
import 'transaction.dart'; // Asegúrate de importar tu modelo de transacción

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedImport = transaction.import.toStringAsFixed(2);
    IconData icon;
    Color iconColor;
    String sign;

    // Determina el icono y color basado en la operación
    if (transaction.operation.toLowerCase() == 'add') {
      icon = Icons.monetization_on; // Ícono para cobrar (añadir)
      iconColor = Colors.green;
      sign = '+';
    } else if (transaction.operation.toLowerCase() == 'subtract') {
      icon = Icons.payment; // Ícono para pagar (restar)
      iconColor = Colors.red;
      sign = '-';
    } else {
      icon = Icons.help; // Ícono de ayuda en caso de operación desconocida
      iconColor = Colors.grey;
      sign = '';
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor), // Icono de la transacción
            SizedBox(width: 16.0), // Espaciado entre el icono y el texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.createDate,
                    style: Theme.of(context).textTheme.headlineSmall, // Fecha en un tamaño más pequeño
                  ),
                  SizedBox(height: 8.0), // Espaciado entre la fecha y el resto
                  Text(
                    '$sign${formattedImport}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
