import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> getUserStatusName(String accessToken) async {
  // Crear el cliente GraphQL con el token de acceso
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  // Configurar las opciones de la consulta
  final QueryOptions options = QueryOptions(
    document: gql(getUserStatusNameQuery), // Query importada desde graphql_queries.dart
  );

  // Realizar la consulta
  final QueryResult result = await client.query(options);

  // Manejar excepciones
  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  // Extraer los datos del resultado
  final Map<String, dynamic>? data = result.data;

  // Verificar si los datos contienen el estado del usuario
  if (data != null && data.containsKey('getUserStatusName')) {
    final userStatus = data['getUserStatusName'];
    if (userStatus is Map<String, dynamic> && userStatus.containsKey('active')) {
      return userStatus['active'] as bool;
    } else {
      throw Exception("No se pudo obtener el estado del usuario.");
    }
  } else {
    throw Exception("No se pudo obtener el estado del usuario.");
  }
}
