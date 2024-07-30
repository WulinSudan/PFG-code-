import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../graphql_client.dart';
import '../graphql_queries.dart';

// Ensure the function is exported correctly
Future<bool> setQrUsed(String accessToken, String qrText) async {
  print("En la clase setQrUsed-----------------------10");
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(setQrUsedMutation),
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
      // Check if result.data is not null before accessing it
      return result.data != null && result.data!['setQrUsed'] == true;
    }
  } catch (e) {
    print('Error inesperado: $e');
    return false;
  }
}
