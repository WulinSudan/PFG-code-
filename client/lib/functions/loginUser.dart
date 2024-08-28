import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Import your GraphQL service
import '../graphql_queries.dart'; // Import your GraphQL queries
import '../dialogs_simples/errorDialog.dart'; // Import your error dialog
import '../dialogs_simples/okDialog.dart'; // Import your success dialog

Future<String?> loginUser(BuildContext context, String username, String password) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient('');

  try {
    // Send the mutation request to the GraphQL server
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(loginUserMutation),
        variables: {
          'input': {
            'name': username,
            'password': password,
          },
        },
      ),
    );

    // Handle the mutation result
    if (result.hasException) {
      // Show an error dialog if there is an exception
      await errorDialog(context, "Authentication failed");
      print("Authentication error: ${result.exception.toString()}");
      return null; // Return null to indicate failure
    } else {
      // On successful authentication, retrieve the access token
      final Map<String, dynamic>? data = result.data?['loginUser'];
      if (data != null) {
        final String accessToken = data['access_token'];

        // Optionally, save the token somewhere (e.g., SharedPreferences)
        await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds before navigating

        // Return the access token
        return accessToken;
      } else {
        // Show an error dialog if the data is unexpectedly null
        await errorDialog(context, "Unexpected error occurred");
        return null; // Return null to indicate failure
      }
    }
  } catch (e) {
    // Handle any unexpected errors
    await errorDialog(context, "An unexpected error occurred");
    print("Request error: $e");
    return null; // Return null to indicate failure
  }
}
