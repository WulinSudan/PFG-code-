import 'dart:async';

import 'package:flutter/material.dart';
import '../pages/account.dart';
import '../pages/account_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import '../functions/fetchUserDate.dart';
import '../functions/addAccount.dart';



//per eliminar un compte, primer pas
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
  } else {
    selectAccountDialog(context,accessToken,accounts,selectedAccount);

  }
}

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


Future<void> makeTransfer(BuildContext context, String accessToken,Account currentAccount, Account selectedAccount) async {
  print("-------------------------------108-------------------------------");
  print(currentAccount.numberAccount);
  print(selectedAccount.numberAccount);
  print(currentAccount.balance);

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(makeTransferMutation),
        variables: {
          'input': {
            'accountOrigen': currentAccount.numberAccount,
            'accountDestin': selectedAccount.numberAccount,
            'import': currentAccount.balance,
          }
        },
      ),
    );

    if (result.hasException) {
      print('Error al ejecutar la mutación: ${result.exception.toString()}');
    } else {
      print('Mutación exitosa');

      removeAccount(context, accessToken, currentAccount.numberAccount);

      // Aquí puedes manejar la respuesta de la mutación si es necesario
      // Por ejemplo, podrías actualizar las cuentas llamando a fetchUserAccounts()
      // O realizar alguna otra acción según tus necesidades
    }
  } catch (e) {
    print('Error inesperado: $e');
  }
}


Future<void> removeAccount(BuildContext context, String accessToken,String accountNumber) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(removeAccountMutation),
        variables: {
          'number_account': accountNumber,
        },
      ),
    );

    if (result.hasException) {
      print('Error al ejecutar la mutación: ${result.exception.toString()}');
    } else {

      // Mostrar SnackBar durante 3 segundos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cuenta eliminada correctamente'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushNamed(
        context,
        '/mainpage',
        arguments: accessToken,
      );
    }
  } catch (e) {
    print('Error inesperado: $e');
  }
}
