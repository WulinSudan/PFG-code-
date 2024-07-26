import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_client.dart';
import 'graphql_queries.dart';
import 'dart:async';


Future<void> addAccount(String accessToken) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(addAccountMutation),
      ),
    );

    if (result.hasException) {
      print('Error al ejecutar la mutación: ${result.exception.toString()}');
    } else {
      print('Mutación exitosa');

      // Aquí puedes manejar la respuesta de la mutación si es necesario
      // Por ejemplo, podrías actualizar las cuentas llamando a fetchUserAccounts()
      // O realizar alguna otra acción según tus necesidades
    }
  } catch (e) {
    print('Error inesperado: $e');
  }
}
