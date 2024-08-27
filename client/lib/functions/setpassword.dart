import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

// Function to set a new password
Future<bool> setPassword(String accessToken, String newOne, String dni) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final MutationOptions options = MutationOptions(
    document: gql(setPasswordMutation),
    variables: {
      'new': newOne,
      'dni': dni,
    },
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      print('GraphQL Exception: ${result.exception}');
      throw Exception('GraphQL Exception: ${result.exception}');
    }

    // Ensure that the `setPassword` field exists and is a boolean
    final bool? success = result.data?['setPassword'] as bool?;

    if (success == null) {
      throw Exception('No data returned from mutation or incorrect data format');
    }

    return success;
  } catch (e) {
    // Error handling, for example, logging the error
    print('Error changing password: $e');
    throw Exception('Failed to change password');
  }
}
