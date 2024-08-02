import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import 'dart:async';

Future<void> addDictionary(
    String accessToken,
    String encrypttext,
    String accountNumber// Asegúrate de que este campo se pase correctamente
    ) async {

  print("Pas 3 en la operacion de addtodictionary-------------------------------------------");
  print(accessToken);
  print(encrypttext);
  print(accountNumber);
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(addDictionaryMutation),
        variables: {
          'input': {
            'encrypt_message': encrypttext,
            'account': accountNumber,
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
        print('Operation: ${data['operation']}'); // Usa el nombre correcto del campo
        print('Create date: ${data['create_date']}'); // Usa el nombre correcto del campo
      } else {
        print('No se recibieron datos en la respuesta.');
      }
    }
  } catch (e) {
    print('Error inesperado: $e');
  }
}
