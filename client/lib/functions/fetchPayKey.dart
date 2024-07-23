import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<String> fetchPayKey(String accessToken, String accountNumber) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final QueryOptions options = QueryOptions(
    document: gql(getPayKeyQuery),
    variables: {'accountNumber': accountNumber},
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  return result.data?['getAccountPayKey'] ?? '';
}
