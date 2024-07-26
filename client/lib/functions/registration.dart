// registration.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<QueryResult> registerUser(String dni, String username, String password) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient('');

  final QueryResult result = await client.mutate(
    MutationOptions(
      document: gql(signUpMutation),
      variables: {
        'input': {
          'dni': dni,
          'name': username,
          'password': password,
        },
      },
    ),
  );

  return result;
}
