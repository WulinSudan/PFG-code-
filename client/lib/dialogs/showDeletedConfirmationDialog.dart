import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import '../pages/account.dart';
import '../pages/account_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import '../functions/fetchUserDate.dart';
import '../functions/addAccount.dart';
import '../functions/removeUserAccount.dart';
import '../functions/maketransfer.dart';
import 'selectAccountDialog.dart';



Future<void> showDeleteConfirmationDialog(BuildContext context, String accessToken, List<Account> accounts, Account selectedAccount) async {
  if (selectedAccount.balance == 0) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar esta cuenta?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                removeAccount(context,accessToken,selectedAccount.numberAccount);
              },
            ),
          ],
        );
      },
    );
  }
  else {
    selectAccountDialog(context,accessToken,accounts,selectedAccount);
  }
}