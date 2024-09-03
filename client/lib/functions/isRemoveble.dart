import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> isRemoveble(String accessToken, String dni) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(isRemovebleQuery), // Asegúrate de que el nombre de la consulta sea correcto
        variables: <String, dynamic>{
          'dni': dni,
        },
      ),
    );

    if (result.hasException) {
      // Manejo de excepciones de la mutación GraphQL
      throw Exception('Error executing isRemovable mutation: ${result.exception.toString()}');
    } else {
      final data = result.data;
      if (data != null && data['isRemoveble'] == true) { // Asegúrate de que el nombre de la clave sea correcto
        // Mutación exitosa y el resultado es verdadero
        return true;
      } else {
        // Mutación exitosa pero el resultado no es verdadero
        return false;
      }
    }
  } catch (e) {
    // Manejo de errores inesperados
    print('Unexpected error: $e');
    return false; // Puedes devolver false en caso de errores inesperados
  }
}
