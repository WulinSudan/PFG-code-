import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';


Future<bool> doQr(String accessToken, String sourceAccount, String destinationAccount, double amount) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(makeTransferMutation),
        variables: {
          'input': {
            'accountOrigen': sourceAccount,
            'accountDestin': destinationAccount,
            'import': amount,
          }
        },
      ),
    );

    if (result.hasException) {
      // Handle GraphQL mutation exceptions
      throw Exception('Error executing mutation: ${result.exception.toString()}');
    } else {
      // Extract the 'success' field from the response
      final bool success = result.data?['makeTransfer']['success'] ?? false;
      if (success) {
        return true; // Indicates the transfer was successful
      } else {
        final String? message = result.data?['makeTransfer']['message'];
        throw Exception('Mutation failed: $message');
      }
    }
  } catch (e) {
    // Handle unexpected errors
    throw Exception('Unexpected error: $e');
  }
}
