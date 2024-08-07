import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> changeUserStatus(String accessToken, String dni) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final MutationOptions options = MutationOptions(
    document: gql(changeUserStatusMutation),
    variables: {
      'dni': dni,
    },
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['changeUserStatus'];
    if (data == null) {
      throw Exception('No data returned from mutation');
    }

    // Asegúrate de que el valor devuelto es un booleano
    if (data is bool) {
      return data;
    } else {
      throw Exception('Returned data is not a boolean');
    }
  } catch (e) {
    // Manejo de errores, por ejemplo, loguear el error
    print('Error setting user status: $e');
    throw Exception('Failed to set user status');
  }
}
