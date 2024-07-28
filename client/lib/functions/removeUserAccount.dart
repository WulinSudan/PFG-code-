import 'dart:async';

import 'package:flutter/material.dart';
import '../pages/account.dart';
import '../pages/account_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import '../functions/fetchUserDate.dart';
import 'addAccount.dart';


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