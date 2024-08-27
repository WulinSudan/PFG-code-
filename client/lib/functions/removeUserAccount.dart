import 'dart:async';

import 'package:flutter/material.dart';
import '../utils/account.dart';
import '../utils/account_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Make sure to import your GraphQL service
import '../graphql_queries.dart';
import '../functions/fetchUserData.dart';
import 'addAccount.dart';

// Function to remove an account
Future<void> removeAccount(BuildContext context, String accessToken, String accountNumber) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(removeAccountMutation),
        variables: {
          'number_account': accountNumber,
        },
      ),
    );

    if (result.hasException) {
      print('Error executing mutation: ${result.exception.toString()}');
    } else {
      // Show SnackBar for 3 seconds
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account successfully deleted'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushNamed(
        context,
        '/mainpage',
        arguments: accessToken,
      );
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}
