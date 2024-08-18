import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<List<String>> getLogs(String accessToken, String dni) async {
  // Crear el cliente GraphQL con el token de acceso
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  // Configurar las opciones de la consulta
  final QueryOptions options = QueryOptions(
    document: gql(getLogsQuery), // Query para obtener los logs
    variables: {'dni': dni}, // Pasar el dni como variable a la consulta
  );

  // Realizar la consulta
  final QueryResult result = await client.query(options);

  // Manejar excepciones
  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  // Extraer los datos del resultado
  final Map<String, dynamic> data = result.data ?? {};

  // Suponiendo que los logs del usuario están en `data['getLogs']`
  if (data.containsKey('getLogs')) {
    List<String> logs = List<String>.from(data['getLogs']);

    // Invertir el orden de los logs
    logs = logs.reversed.toList();

    return logs;
  } else {
    throw Exception("No se pudieron obtener los logs del usuario.");
  }
}
