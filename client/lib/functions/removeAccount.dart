import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';

Future<void> removeAccount(BuildContext context, String accessToken, String accountNumber) async {
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
