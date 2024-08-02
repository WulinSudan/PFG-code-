import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<String> getOrigenAccount(String accessToken, String qrText) async {
  print("En la función getOrigenAccount");

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final QueryOptions options = QueryOptions(
    document: gql(getOrigenAccountQuery),
    variables: {'qrtext': qrText},
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  return result.data?['getOrigenAccount'] ?? '';
}
