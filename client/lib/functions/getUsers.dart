import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../utils/user.dart'; // Asegúrate de importar la clase User

Future<List<User>> getUsers(String accessToken) async {
  print("En la función getUsers");

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final QueryOptions options = QueryOptions(
    document: gql(getUsersQuery),
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    print("Error en la consulta: ${result.exception.toString()}");
    throw Exception(result.exception.toString());
  }

  // Imprimir el resultado de la consulta para depuración
  print("Resultado de la consulta: ${result.data}");

  // Cambiar 'getUsers' a la clave correcta según tu resultado
  final List<dynamic>? usersJson = result.data?['getUsers'];

  if (usersJson == null) {
    print('No se recibieron datos de usuarios');
    throw Exception('No se recibieron datos de usuarios');
  }

  // Imprimir los datos JSON para verificar su contenido
  print("Datos JSON de usuarios: $usersJson");

  // Convertir los datos JSON a una lista de objetos User
  final List<User> users = usersJson.map((json) => User.fromJson(json)).toList();

  // Imprimir la lista de usuarios para verificar que la conversión fue correcta
  print("Usuarios convertidos: $users");

  return users;
}
