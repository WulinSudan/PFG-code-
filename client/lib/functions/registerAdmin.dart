import 'dart:async';
import 'package:client/dialogs_simples/errorDialog.dart';
import 'package:client/dialogs_simples/okDialog.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Import your GraphQL service
import '../graphql_queries.dart'; // Import your GraphQL queries

Future<bool> registerAdmin(BuildContext context, String dni, String username, String password) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient('');

  final QueryResult result = await client.mutate(
    MutationOptions(
      document: gql(signUpAdminMutation),
      variables: {
        'input': {
          'dni': dni,
          'name': username,
          'password': password,
        },
      },
    ),
  );

  if (result.hasException) {
    errorDialog(context, 'Error in registration');
    return false; // Registration failed
  } else {
    okDialog(context, "Registration successful");
    return true; // Registration successful
  }
}
