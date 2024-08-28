import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> getUserStatusDni(String accessToken, String dni) async {

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final QueryOptions options = QueryOptions(
    document: gql(getUserStatusDniQuery),
    variables: {'dni': dni},
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    print('GraphQL Exception: ${result.exception.toString()}');
    throw Exception(result.exception.toString());
  }

  final bool status = result.data?['getUserStatusDni'] ?? false;

  return status;
}
