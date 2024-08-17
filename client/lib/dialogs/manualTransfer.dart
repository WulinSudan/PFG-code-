import 'package:client/functions/makeTransfer.dart';
import 'package:flutter/material.dart';
import '../functions/doQr.dart';  // Importar la función doQr
import '../pages/account.dart'; // Importar la clase Account si es necesario
import '../functions/doQr.dart';
import '../functions/addTransaction.dart';
import '../functions/getAccountBalance.dart';

Future<void> showManualTransferDialog(BuildContext context, String accessToken, Account currentAccount) async {
  final accountNumberController = TextEditingController();
  final amountController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Evita que el diálogo se cierre al tocar fuera de él
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Transferencia Manual'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: accountNumberController,
                decoration: InputDecoration(labelText: 'Número de Cuenta Destino'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Importe'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo sin hacer cambios
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final accountNumber = accountNumberController.text;
              final amount = double.tryParse(amountController.text) ?? 0.0;

              if (accountNumber.isEmpty || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Por favor, ingresa un número de cuenta válido y un importe positivo')),
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
                    SnackBar(content: Text('Transferencia realizada con éxito')),
                  );
                  // Cierra el diálogo después de la transferencia
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo realizar la transferencia')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al realizar la transferencia: $e')),
                );
              }
            },
            child: Text('Transferir'),
          ),
        ],
      );
    },
  );
}
