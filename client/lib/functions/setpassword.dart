import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> setPassword(String accessToken, String newOne, String dni) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final MutationOptions options = MutationOptions(
    document: gql(setPasswordMutation),
    variables: {
      'new': newOne,
      'dni': dni,
    },
  );

  try {
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      // Manejo de excepciones detallado
      print('GraphQL Exception: ${result.exception}');
      throw Exception('GraphQL Exception: ${result.exception}');
    }

    // Asegúrate de que el campo `setPassword` existe y es un booleano
    final bool? success = result.data?['setPassword'] as bool?;

    if (success == null) {
      throw Exception('No data returned from mutation or incorrect data format');
    }

    return success;
  } catch (e) {
    // Manejo de errores, por ejemplo, loguear el error
    print('Error changing password: $e');
    throw Exception('Failed to change password');
  }
}
