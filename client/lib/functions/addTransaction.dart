import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import 'dart:async';

Future<void> addTransaction(String accessToken, String accountNumber, String operation, double importAmount) async {

  print("En la funcion add Transaction--------------------------");
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(addTransactionMutation),
        variables: {
          'input': {
            'operation': operation,
            'accountNumber': accountNumber,
            'import': importAmount,
          }
        },
      ),
    );

    if (result.hasException) {
      print('Error al ejecutar la mutación: ${result.exception.toString()}');
    } else {
      print('Mutación exitosa');

      // Procesa la respuesta si es necesario
      final Map<String, dynamic> data = result.data ?? {}; // Proporciona un mapa vacío si result.data es null
      print('Datos de la mutación: ${data.toString()}');
    }
  } catch (e) {
    print('Error inesperado: $e');
  }
}
