import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import 'dart:async';

Future<void> addTransaction(
    String accessToken,
    String accountNumber,
    String operation,
    double importAmount,
    double balance // Ensure this matches the expected type
    ) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(addTransactionMutation),
        variables: {
          'input': {
            'operation': operation,
            'accountNumber': accountNumber,
            'import': importAmount,
            'balance': balance,
          },
        },
      ),
    );

    if (result.hasException) {
      // Handle GraphQL mutation exceptions
      throw Exception('Error executing mutation: ${result.exception.toString()}');
    } else {
      // Process successful mutation response
      final Map<String, dynamic> data = result.data?['addTransaction'] ?? {}; // Update 'addTransaction' to the correct field name if needed
    }
  } catch (e) {
    // Handle unexpected errors
    throw Exception('Unexpected error: $e');
  }
}
