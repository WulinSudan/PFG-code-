import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import 'dart:async';

Future<void> addKeyToDictionary(
    String accessToken,
    String encrypttext,
    String accountNumber,
    String operation, // Cambiado a String
    ) async {

  print("en la operacion de addkeytodictionary-------------------------------------------");
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(addKeyToDictionaryMutation),
        variables: {
          'input': {
            'encrypt_message': encrypttext,
            'account': accountNumber,
            'pay': operation, // Asegúrate de que esto sea una cadena en la mutación
          },
        },
      ),
    );

    if (result.hasException) {
      // Manejo de excepciones
      print('Error al ejecutar la mutación: ${result.exception.toString()}');
    } else {
      print('Mutación exitosa');

      // Manejar los datos de la respuesta
      final data = result.data?['addDictionary'];
      if (data != null) {
        print('Encrypt message: ${data['encrypt_message']}');
        print('Account: ${data['account']}');
        print('Operation: ${data['pay']}'); // Asume que 'pay' es la cadena 'operation'
        print('Create date: ${data['last_pay_create_date']}'); // Asume que 'last_pay_create_date' es el campo correcto
      } else {
        print('No se recibieron datos en la respuesta.');
      }
    }
  } catch (e) {
    print('Error inesperado: $e');
  }
}
