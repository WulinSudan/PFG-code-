import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_queries.dart';
import 'pages/welcomepage.dart';
import 'pages/login.dart';


import 'graphql_client.dart'; // Importa el archivo que acabas de crear.

void main() {
  runApp(createGraphQLProvider());
}


class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/welcomepage',
      routes: {
        '/welcomepage': (context) => WelcomePage(),
        '/login': (context) => Login(), // Asumiendo que tienes una clase llamada Login para tu pantalla de inicio de sesión.
      },
    );
  }
}


