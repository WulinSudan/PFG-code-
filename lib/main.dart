import 'package:client/pages/mainpage.dart';
import 'package:flutter/material.dart';
import 'pages/welcomepage.dart';
import 'pages/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/mainpage': (context) {
          final String? accessToken = ModalRoute.of(context)?.settings.arguments as String?;
          return MainPage(accessToken: accessToken!);
        },
        '/welcomepage': (context) => WelcomePage(),
        '/login': (context) => Login(), // Asumiendo que tienes una clase llamada Login para tu pantalla de inicio de sesión.
      },
    );
  }

}


