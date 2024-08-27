import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import 'dart:async';

Future<void> addDictionary(
    String accessToken,
    String encryptText,
    String accountNumber // Ensure this field is passed correctly
    ) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(addDictionaryMutation),
        variables: {
          'input': {
            'encrypt_message': encryptText,
            'account': accountNumber,
          },
        },
      ),
    );

    if (result.hasException) {
      // Handle exceptions from the mutation
      throw Exception('Error executing mutation: ${result.exception.toString()}');
    } else {
      // Handle successful response
      final data = result.data?['addDictionary'];
      if (data == null) {
        throw Exception('No data received in the response.');
      }
      // Further processing of `data` can be done here if needed
    }
  } catch (e) {
    // Handle unexpected errors
    throw Exception('Unexpected error: $e');
  }
}
