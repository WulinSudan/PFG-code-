import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> getAccountStatus(String accessToken, String accountNumber) async {
  print("En la función getAccountStatus");

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final QueryOptions options = QueryOptions(
    document: gql(getAccountStatusQuery),
    variables: {'accountNumber': accountNumber},
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    print('GraphQL Exception: ${result.exception.toString()}');
    throw Exception(result.exception.toString());
  }

  // Asegúrate de que el nombre del campo coincide con el definido en tu consulta GraphQL.
  final bool status = result.data?['getAccountStatus'] ?? false;

  return status;
}
