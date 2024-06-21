import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../pages/account.dart';

typedef UpdateCallback = void Function(String?, String?, List<dynamic>);

Future<void> fetchUserData(String accessToken, UpdateCallback updateCallback) async {
  String? userName;
  String? dni;
  List<dynamic> listAccounts = [];

  await fetchUserInfo(accessToken, (name, id) {
    userName = name;
    dni = id;
    updateCallback(userName, dni, listAccounts);
  });

  await fetchUserAccounts(accessToken, dni, (accounts) {
    listAccounts = accounts;
    updateCallback(userName, dni, listAccounts);
  });
}

Future<void> fetchUserInfo(String accessToken, Function(String?, String?) callback) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(meQuery),
      ),
    );

    if (result.hasException) {
      print("Error al obtener el nombre del usuario: ${result.exception}");
    } else {
      final String? userName = result.data!['me']['name'];
      final String? dni = result.data!['me']['dni'];
      callback(userName, dni);
    }
  } catch (e) {
    print('Ocurrió un error inesperado: $e');
  }
}

Future<void> fetchUserAccounts(String accessToken, String? dni, Function(List<dynamic>) updateAccounts) async {
  try {
    final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

    final QueryOptions options = QueryOptions(
      document: gql(getAccountsQuery),
      variables: <String, dynamic>{
        'dni': dni,
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print("Error al obtener las cuentas del usuario: ${result.exception}");
    } else if (result.data != null && result.data!['getUserAccountsInfoByDni'] != null) {
      List<dynamic> accounts = result.data!['getUserAccountsInfoByDni'];
      updateAccounts(accounts);
    }
  } catch (e) {
    print('Ocurrió un error inesperado: $e');
  }
}
