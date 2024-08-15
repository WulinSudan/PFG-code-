import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<String> getUserRole(String accessToken, String name) async {
  print("En la función getUserRole");

  // Crear el cliente GraphQL con el token de acceso
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  // Configurar las opciones de la consulta
  final QueryOptions options = QueryOptions(
    document: gql(getUserRoleQuery), // Query importada desde graphql_queries.dart
    variables: {'name': name}, // Pasar el nombre como variable a la consulta
  );

  // Realizar la consulta
  final QueryResult result = await client.query(options);

  // Manejar excepciones
  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  // Extraer los datos del resultado
  final Map<String, dynamic> data = result.data ?? {};

  // Suponiendo que el DNI del usuario está en `data['getUserRole']`
  if (data.containsKey('getUserRole')) {
    return data['getUserRole'] as String;
  } else {
    throw Exception("No se pudo obtener el DNI del usuario.");
  }
}
