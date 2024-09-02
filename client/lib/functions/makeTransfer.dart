import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/account.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import 'removeUserAccount.dart';


Future<bool> makeTransfer(BuildContext context, String accessToken, Account currentAccount, Account selectedAccount) async {

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(makeTransferMutation),
        variables: {
          'input': {
            'accountOrigen': currentAccount.numberAccount,
            'accountDestin': selectedAccount.numberAccount,
            'import': currentAccount.balance,
          }
        },
      ),
    );

    if (result.hasException) {
      print('Error executing mutation: ${result.exception.toString()}');
      return false; // Indicates that the transfer was not successful
    } else {
      // Extract the 'success' field from the response
      final bool success = result.data?['makeTransfer']['success'] ?? false;
      if (success) {
        print('Mutation successful');

        // Call the function to remove the account if necessary
        //await removeAccount(context, accessToken, currentAccount.numberAccount);

      } else {
        print('The mutation failed: ${result.data?['makeTransfer']['message']}');
      }
      return success; // Indicates whether the transfer was successful or not
    }
  } catch (e) {
    print('Unexpected error: $e');
    return false; // Indicates that the transfer was not successful
  }
}
