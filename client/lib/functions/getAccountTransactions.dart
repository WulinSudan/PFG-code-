import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../utils/transaction.dart'; // Adjust the path as needed

Future<List<Transaction>> getAccountTransactions(String accessToken, String accountNumber) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final QueryOptions options = QueryOptions(
    document: gql(getAccountTransactionsQuery),
    variables: {'accountNumber': accountNumber},
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  print('Received data: ${result.data}'); // Print data for verification

  final transactionsJson = result.data?['getAccountTransactions'] as List<dynamic>?;

  if (transactionsJson == null) {
    return [];
  }

  List<Transaction> transactions = transactionsJson.map((json) {
    print('Transaction data: $json'); // Print each transaction
    return Transaction.fromJson(json as Map<String, dynamic>);
  }).toList();

  // Sort transactions in descending order by creation date
  transactions.sort((a, b) => b.createDate.compareTo(a.createDate));

  return transactions;
}
