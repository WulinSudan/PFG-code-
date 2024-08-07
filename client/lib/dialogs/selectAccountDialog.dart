import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import '../pages/account.dart';
import '../pages/account_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import '../functions/fetchUserData.dart';
import '../functions/addAccount.dart';
import '../functions/removeUserAccount.dart';
import '../functions/maketransfer.dart';



Future<void> selectAccountDialog(BuildContext context, String accesToken, List<Account> accounts, Account currentAccount) async {

  // Filtrar las cuentas excluyendo la cuenta actual
  List<Account> filteredAccounts = accounts.where((account) => account.numberAccount != currentAccount.numberAccount).toList();

  // Variable para guardar la cuenta seleccionada
  Account? selectedAccount;

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Seleccionar una cuenta para vaciar el saldo'),
            content: SingleChildScrollView(
              child: ListBody(
                children: filteredAccounts.map((account) {
                  return ListTile(
                    title: Text('${account.numberAccount} - Saldo: ${account.balance.toStringAsFixed(2)}'),
                    tileColor: selectedAccount == account ? Colors.blue.withOpacity(0.5) : null,
                    onTap: () {
                      setState(() {
                        selectedAccount = account;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Aceptar'),
                onPressed: selectedAccount != null
                    ? () {
                  if (selectedAccount != null) {
                    //Navigator.of(context).pop();
                    makeTransfer(context, accesToken, currentAccount,selectedAccount!);

                  }
                }
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: selectedAccount != null ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
