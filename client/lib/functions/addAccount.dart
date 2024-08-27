import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import 'dart:async';

Future<void> addAccount(String accessToken) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(addAccountMutation),
      ),
    );

    if (result.hasException) {
      print('Error executing the mutation: ${result.exception.toString()}');
    } else {
      print('Mutation successful');

    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}
