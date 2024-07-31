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
      print('Error al ejecutar la mutación checkEnable: ${result.exception.toString()}');
      return false;
    } else {
      final data = result.data;
      if (data != null && data['checkEnable'] == true) {
        print('Mutación exitosa y el resultado es true');
        return true;
      } else {
        print('Mutación exitosa pero el resultado no es true');
        return false;
      }
    }
  } catch (e) {
    print('Error inesperado: $e');
    return false;
  }
}
