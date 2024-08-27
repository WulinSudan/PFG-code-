import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../utils/account.dart';

Future<List<Account>> getAccounts(String accessToken, String dni) async {

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final QueryOptions options = QueryOptions(
    document: gql(getAccountsQuery),
    variables: {'dni': dni},
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  final List<dynamic>? accountsJson = result.data?['getUserAccountsInfoByDni'];

  print(accountsJson);

  if (accountsJson == null) {
    throw Exception('No account data received');
  }

  // Convert JSON data to a list of Account objects
  return accountsJson.map((json) => Account.fromJson(json)).toList();
}
