import 'package:client/pages/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_queries.dart';
import 'pages/welcomepage.dart';
import 'pages/login.dart';
import 'graphql_client.dart';
import 'graphql_client.dart'; // Importa el archivo que acabas de crear.
import 'mutation.dart';
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
      initialRoute: '/mutation',
      routes: {
        '/mainpage': (context) {
            final accessToken = ModalRoute.of(context)!.settings.arguments as String?;
            return MainPage(accessToken: accessToken);
        },
        '/mutation': (context) => MyMutation(),
        '/welcomepage': (context) => WelcomePage(),
        '/login': (context) => Login(), // Asumiendo que tienes una clase llamada Login para tu pantalla de inicio de sesión.
      },
    );
  }

}


