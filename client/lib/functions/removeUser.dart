import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../utils/account.dart';
import '../utils/account_card.dart';
import '../graphql_client.dart'; // Make sure to import your GraphQL service
import '../graphql_queries.dart';
import '../functions/fetchUserData.dart';
import 'addAccount.dart';

// Function to remove a user
Future<void> removeUser(BuildContext context, String accessToken, String dni) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(deleteUserMutation),
        variables: {
          'dni': dni,
        },
      ),
    );

    if (result.hasException) {
      print('Error executing mutation: ${result.exception.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: ${result.exception.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User successfully deleted'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    print('Unexpected error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An unexpected error occurred: $e'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
