import 'dart:async';

import 'package:flutter/material.dart';
import '../pages/account.dart';
import '../pages/account_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import '../functions/fetchUserDate.dart';
import '../addAccount.dart';
import 'removeUserAccount.dart';




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

