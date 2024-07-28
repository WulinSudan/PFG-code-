import 'dart:async';

import 'package:flutter/material.dart';
import '../pages/account.dart';
import '../pages/account_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import '../functions/fetchUserDate.dart';
import 'removeUserAccount.dart';

// Función para realizar la transferencia
Future<bool> makeTransfer(BuildContext context, String accessToken, Account currentAccount, Account selectedAccount) async {
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
      return false; // Indica que la transferencia no fue exitosa
    } else {
      // Extraer el campo 'success' de la respuesta
      final bool success = result.data?['makeTransfer']['success'] ?? false;
      if (success) {
        print('Mutación exitosa');

        // Llama a la función para eliminar la cuenta si es necesario
        await removeAccount(context, accessToken, currentAccount.numberAccount);

        // Aquí puedes manejar la respuesta de la mutación si es necesario
        // Por ejemplo, podrías actualizar las cuentas llamando a fetchUserAccounts()
        // O realizar alguna otra acción según tus necesidades
      } else {
        print('La mutación falló: ${result.data?['makeTransfer']['message']}');
      }
      return success; // Indica si la transferencia fue exitosa o no
    }
  } catch (e) {
    print('Error inesperado: $e');
    return false; // Indica que la transferencia no fue exitosa
  }
}
