import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'main.dart'; // Importa MyApp desde donde sea que esté definido.
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_queries.dart';
import 'pages/login.dart';


GraphQLProvider createGraphQLProvider() {
  //final HttpLink httpLink = HttpLink("http://192.168.1.29:4000/");
  final HttpLink httpLink = HttpLink("http://172.31.51.220:4000/");

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );


  // prueba para mostrar todos los usuarios

  // client.value.query(QueryOptions(document: gql(allUsersGraphql)))
  //     .then((result) {
  //   if (result.hasException) {
  //     print("Error en la consulta: ${result.exception.toString()}");
  //   } else {
  //     print("Consulta exitosa: ${result.data}");
  //   }
  // })
  //     .catchError((error) {
  //   print("Error de conexión: $error");
  // });


/*  client.value.mutate(MutationOptions(
    document: gql(loginUserMutation),
    variables: {
      'input': {
        'name': 'Pere',
        'password': 'Pere123',
      }
    },
  ))
      .then((result) {
    if (result.hasException) {
      print("Error en la mutación: ${result.exception.toString()}");
    } else {
      print("Respuesta de la mutación: ${result.data}");
      //print("Token de acceso: ${result.data['loginUser']['access_token']}");
    }
  })
      .catchError((error) {
    print("Error de conexión: $error");
  });*/


  return GraphQLProvider(
    client: client,
    child: MyApp(
      
    ),
  );
}



