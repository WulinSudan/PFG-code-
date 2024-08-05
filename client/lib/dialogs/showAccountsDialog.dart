import 'package:flutter/material.dart';
import '../pages/account.dart'; // Asegúrate de que este es el nombre correcto del archivo de la clase Account
import '../functions/getAccounts.dart'; // Asegúrate de importar la función getAccounts

Future<void> showAccountsDialog(BuildContext context, String accessToken, String dni) async {
  List<Account> accounts = [];

  try {
    accounts = await getAccounts(accessToken, dni); // Obtén las cuentas aquí
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al obtener las cuentas: ${e.toString()}'),
      ),
    );
    return;
  }

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Cuentas del Usuario'),
        content: SingleChildScrollView(
          child: ListBody(
            children: accounts.map((account) {
              return ListTile(
                title: Text('Cuenta ID: ${account.numberAccount}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saldo: ${account.balance}'),
                    Text('Activa: ${account.active}'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cerrar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
