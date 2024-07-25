import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<String?> getOperation(String accessToken, String qrtext) async {

  print("---------------En la operacion getOperation");
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(getOperationQuery),
        variables: <String, dynamic>{
          'qrtext': qrtext,
        },
      ),
    );

    if (result.hasException) {
      print('Error al ejecutar la consulta: ${result.exception.toString()}');
      return null;
    } else {
      print('Consulta exitosa');

      // Extraer la cuenta de la respuesta
      final String? operation = result.data?['getOperation'] as String?;
      return operation;
    }
  } catch (e) {
    print('Error inesperado: $e');
    return null;
  }
}
