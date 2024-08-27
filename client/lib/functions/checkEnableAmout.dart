import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> checkEnableAmount(String accessToken, String accountNumber, double amount) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(checkEnableAmountQuery),
        variables: <String, dynamic>{
          'accountNumber': accountNumber,
          'amount': amount,
        },
      ),
    );

    if (result.hasException) {
      // Handle GraphQL mutation exceptions
      throw Exception('Error executing checkEnableAmount mutation: ${result.exception.toString()}');
    } else {
      final data = result.data;
      if (data != null && data['checkEnableAmount'] == true) {
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
