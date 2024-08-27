import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> changePassword(String accessToken, String old, String newOne) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final MutationOptions options = MutationOptions(
    document: gql(changePasswordMutation),
    variables: {
      'old': old,
      'new': newOne,
    },
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {

      print('GraphQL Exception: ${result.exception}');
      throw Exception('GraphQL Exception: ${result.exception}');
    }

    final bool? changed = result.data?['changePassword'] as bool?;

    if (changed == null) {
      throw Exception('No data returned from mutation or incorrect data format');
    }

    return changed;
  } catch (e) {

    print('Error changing password: $e');
    throw Exception('Failed to change password');
  }
}
