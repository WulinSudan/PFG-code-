import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> checkSufficientAmount(String accessToken, String accountNumber, double amount) async {
  print("Dentro de la función checkSufficientAmount");

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(checkSufficientAmountQuery),
        variables: <String, dynamic>{
          'accountNumber': accountNumber,
          'amount': amount,
        },
      ),
    );

    if (result.hasException) {
      print('Error al ejecutar la mutación checkSufficientAmount: ${result.exception.toString()}');
      return false;
    } else {
      final data = result.data;
      if (data != null && data['checkSufficientAmount'] == true) {
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
