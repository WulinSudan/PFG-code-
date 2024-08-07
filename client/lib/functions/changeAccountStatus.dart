import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> changeAccountStatus(String accessToken, String accountNumber) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final MutationOptions options = MutationOptions(
    document: gql(changeAccountStatusMutation),
    variables: {
      'accountNumber': accountNumber,
    },
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['changeAccountStatus'];
    if (data == null) {
      throw Exception('No data returned from mutation');
    }

    // Asegúrate de que el valor devuelto es un booleano
    return data as bool;
  } catch (e) {
    // Manejo de errores, por ejemplo, loguear el error
    print('Error setting account as inactive: $e');
    throw Exception('Failed to set account as inactive');
  }
}