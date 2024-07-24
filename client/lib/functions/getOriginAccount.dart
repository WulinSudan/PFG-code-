import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<String?> getOrigenAccount(String accessToken, String qrtext) async {
  print("Encountrar la cuenta de origen");

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(getOrigenAccountQuery),
        variables: <String, dynamic>{
          'qrtext': qrtext,
        },
      ),
    );

    if (result.hasException) {
      print('Error al ejecutar la consulta: ${result.exception.toString()}');
      return null;
    } else {
      print('Consulta exitosa, cuenta origen encontrada');

      // Extraer la cuenta de la respuesta
      final String? account = result.data?['getOriginAccount'] as String?;
      return account;
    }
  } catch (e) {
    print('Error inesperado: $e');
    return null;
  }
}
