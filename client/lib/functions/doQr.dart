import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../functions/encrypt.dart'; // Asegúrate de que esta función se está usando correctamente
import '../functions/fetchPayKey.dart';

Future<bool> doQr(String accessToken, String origen, String desti, double import) async {
  print("------------------------12-----doQR------------------------");
  print('Origen: $origen');
  print('Destino: $desti');
  print('Importe: $import');

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(makeTransferMutation),
        variables: {
          'input': {
            'accountOrigen': origen,
            'accountDestin': desti,
            'import': import,
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
        return true; // Indica que la transferencia fue exitosa
      } else {
        print('La mutación falló: ${result.data?['makeTransfer']['message']}');
        return false; // Indica que la transferencia no fue exitosa
      }
    }
  } catch (e) {
    print('Error inesperado: $e');
    return false; // Indica que la transferencia no fue exitosa
  }
}
