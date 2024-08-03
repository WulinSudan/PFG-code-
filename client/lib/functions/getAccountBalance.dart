import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<double> getAccountBalance(String accessToken, String account) async {
  print("En la función getAccountBalance");

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final QueryOptions options = QueryOptions(
    document: gql(getAccountBalanceQuery),
    variables: {'accountNumber': account},
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  // Verifica si el dato no es nulo y es del tipo correcto
  final balance = result.data?['getAccountBalance'];
  if (balance is double) {
    return balance;
  } else if (balance is int) {
    return balance.toDouble();
  } else {
    throw Exception('Invalid balance type');
  }
}
