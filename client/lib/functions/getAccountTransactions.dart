import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../utils/transaction.dart'; // Ajusta la ruta según sea necesario

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

  print('Datos recibidos: ${result.data}'); // Imprime los datos para verificar

  final transactionsJson = result.data?['getAccountTransactions'] as List<dynamic>?;

  if (transactionsJson == null) {
    return [];
  }

  List<Transaction> transactions = transactionsJson.map((json) {
    print('Datos de transacción: $json'); // Imprime cada transacción
    return Transaction.fromJson(json as Map<String, dynamic>);
  }).toList();

  // Ordena las transacciones en orden descendente por fecha de creación
  transactions.sort((a, b) => b.createDate.compareTo(a.createDate));

  return transactions;
}
