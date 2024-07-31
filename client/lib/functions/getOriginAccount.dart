import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<String?> getOrigenAccount(String accessToken, String qrtext) async {


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
      // Manejo de errores más detallado
      print('Error al ejecutar la consulta: ${result.exception.toString()}');
      return null;
    } else {
      print('Consulta exitosa, cuenta origen encontrada');

      // Asegúrate de que el campo 'getOriginAccount' esté presente en el resultado
      final String? account = result.data?['getOriginAccount'] as String?;
      if (account != null) {
        print("-----------------En la funcion getOrigenAccount, la cuenta que se ha generado el codi qr: $account");
      } else {
        print('No se encontró la cuenta de origen en la respuesta.');
      }
      return account;
    }
  } catch (e) {
    // Manejo de errores inesperados
    print('Error inesperado: $e');
    return null;
  }
}
