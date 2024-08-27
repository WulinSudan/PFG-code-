import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

// Ensure the function is exported correctly
Future<bool> checkEnable(String accessToken, String qrText) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(checkEnableMutation),
        variables: <String, dynamic>{
          'qrtext': qrText,
        },
      ),
    );

    if (result.hasException) {
      // Handle GraphQL mutation exceptions
      throw Exception('Error executing checkEnable mutation: ${result.exception.toString()}');
    } else {
      final data = result.data;
      if (data != null && data['checkEnable'] == true) {
        // Mutation successful and result is true
        return true;
      } else {
        // Mutation successful but result is not true
        return false;
      }
    }
  } catch (e) {
    // Handle unexpected errors
    throw Exception('Unexpected error: $e');
  }
}
