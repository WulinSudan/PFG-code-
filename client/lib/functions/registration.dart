import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> registerUser(String dni, String username, String password) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient('');

  final MutationOptions options = MutationOptions(
    document: gql(signUpMutation),
    variables: {
      'input': {
        'dni': dni,
        'name': username,
        'password': password,
      },
    },
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      print('GraphQL Exception: ${result.exception.toString()}');
      return false;
    } else {
      return true;
    }
  } catch (e) {
    print('Error during registration: $e');
    return false;
  }
}
