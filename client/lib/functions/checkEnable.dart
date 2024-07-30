import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../graphql_client.dart';
import '../graphql_queries.dart';

// Asegúrate de que la función está exportada correctamente
Future<bool> checkEnable(String accessToken, String qrText) async {
  print("Dins de la funcio chechEnable-----10");
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(checkEnableMutation),
        variables: <String, dynamic>{
          'qrtext': qrText,
        },
      ),
    );

    if (result.hasException) {
      print('Error al ejecutar la mutación: ${result.exception.toString()}');
      return false;
    } else {
      print('Mutación exitosa');
      return true;
    }
  } catch (e) {
    print('Error inesperado: $e');
    return false;
  }
}
