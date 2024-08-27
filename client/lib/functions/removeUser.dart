import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../utils/account.dart';
import '../utils/account_card.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import '../functions/fetchUserData.dart';
import 'addAccount.dart';

Future<void> removeUser(BuildContext context, String accessToken, String dni) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(deleteUserMutation),
        variables: {
          'dni': dni,
        },
      ),
    );

    if (result.hasException) {
      print('Error al ejecutar la mutación: ${result.exception.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el usuario: ${result.exception.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario eliminado correctamente'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    print('Error inesperado: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ocurrió un error inesperado: $e'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
