import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../graphql_client.dart';
import '../graphql_queries.dart';


Future<String?> setNewKey(String accessToken, String accountNumber) async {

  print("para generar una nueva comtrasenya");
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);


  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(setNewKeyMutation),
        variables: <String, dynamic>{
          'accountNumber': accountNumber,
        },
      ),
    );

    if (result.hasException) {
      print('Error al ejecutar la mutación: ${result.exception.toString()}');
      return null;
    } else {
      print('Mutación exitosa');

      // Extraer la nueva clave de la respuesta
      final String? newKey = result.data?['setNewKey'] as String?;
      return newKey;
    }
  } catch (e) {
    print('Error inesperado: $e');
    return null;
  }
}
