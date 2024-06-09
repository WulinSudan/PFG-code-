import 'package:flutter/material.dart';
import 'pages/welcomepage.dart';
import 'pages/qrmainpage.dart';
import 'pages/login.dart';
import 'pages/mainpage.dart';
import 'pages/registration.dart';
import 'mutation.dart';
import 'pages/chargepage.dart';
import 'pages/paymentpage.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/paymentpage': (context) => PaymentPage(),
        '/chargepage': (context) => ChargePage(),
        '/mutation': (context) => MutationPage(),
        '/mainpage': (context) {
          final String? accessToken = ModalRoute.of(context)?.settings.arguments as String?;
          return MainPage(accessToken: accessToken!);
        },
        '/registration': (context) => RegistrationPage(),
        '/qrmainpage': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is String) {
            // Si los argumentos son simplemente un String, puedes manejarlos aquí
            return QrMainPage(accessToken: args);
          } else if (args is Map<String, dynamic>) {
            // Si los argumentos son un mapa, puedes extraer el accessToken del mapa
            final accessToken = args['accessToken'] as String?;
            return QrMainPage(accessToken: accessToken ?? '');
          } else {
            // Maneja otros tipos de argumentos o errores aquí
            throw ArgumentError('Invalid arguments provided for route /qrmainpage');
          }
        },
        '/welcomepage': (context) => WelcomePage(),
        '/login': (context) => Login(), // Asumiendo que tienes una clase llamada Login para tu pantalla de inicio de sesión.
      },
    );
  }

}
