import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../functions/fetchUserDate.dart';
import '../functions/addAccount.dart';
import '../functions/encrypt.dart';
import '../functions/fetchPayKey.dart';// Función para realizar la transferencia



Future<void> doQr(String accessToken, String origen, String desti, double import) async {
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
      // Manejo de error adicional según sea necesario
    } else {
      print('Mutación exitosa');
      // Aquí puedes manejar la respuesta de la mutación si es necesario
      // Por ejemplo, podrías actualizar las cuentas llamando a fetchUserAccounts()
      // O realizar alguna otra acción según tus necesidades
    }
  } catch (e) {
    print('Error inesperado: $e');
    // Manejo de error adicional según sea necesario
  }
}