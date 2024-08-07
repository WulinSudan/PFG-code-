import 'package:flutter/material.dart';
import '../pages/account.dart'; // Asegúrate de que este es el nombre correcto del archivo de la clase Account
import '../functions/getAccounts.dart'; // Asegúrate de importar la función getAccounts
import '../pages/account_card_admin.dart'; // Asegúrate de que este es el nombre correcto del archivo de la clase AccountCardAdmin
import '../functions/changeAccountStatus.dart'; // Asegúrate de importar la función setDesactiveAccount

Future<void> showAccountsDialog(BuildContext context, String accessToken, String dni) async {
  List<Account> accounts = [];
  Account? selectedAccount;

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
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Cuentas del Usuario'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: accounts.map((account) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAccount = account;
                      });
                    },
                    child: AccountCardAdmin(
                      account: account,
                      isSelected: selectedAccount == account,
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              if (selectedAccount != null)
                TextButton(
                  child: Text('Change status'),
                  onPressed: () async {
                    try {
                      bool success = await changeAccountStatus(accessToken, selectedAccount!.numberAccount);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cuenta ${selectedAccount!.numberAccount} desactivada.'),
                          ),
                        );
                        // Espera 2 segundos antes de cerrar el diálogo
                        await Future.delayed(Duration(seconds: 2));
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No se pudo desactivar la cuenta.'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al desactivar la cuenta: ${e.toString()}'),
                        ),
                      );
                    }
                  },
                ),
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
    },
  );
}
