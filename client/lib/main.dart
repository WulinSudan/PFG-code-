import 'package:flutter/material.dart';
import 'pages/welcomepage.dart';
import 'pages/login.dart';
import 'pages/mainpage.dart';
import 'pages/registration.dart';
import 'mutation.dart';
import 'pages/chargepage.dart';
import 'pages/paymentpage.dart';
import 'pages/qrscanner.dart';
import 'pages/qrgestion.dart';
import 'pages/account.dart';
import 'pages/setMaxPayImport.dart';

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
        '/setMaxPayImport': (context) {
          final String? accessToken = ModalRoute.of(context)?.settings.arguments as String?;
          return SetMaxPayImport(accessToken: accessToken!);
        },
        '/qrgestion': (context) => QrGestion(),
        '/qrscanner': (context) {
          // Extraer los argumentos de la ruta
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String accessToken = args['accessToken'] as String;
          final Account account = args['account'] as Account;
          // Devolver el widget QrScanner con los argumentos pasados
          return QrScanner(accessToken: accessToken, account: account);
        },
        '/paymentpage': (context) => PaymentPage(),
        '/chargepage': (context) => ChargePage(),
        '/mutation': (context) => MutationPage(),
        '/mainpage': (context) {
          final String? accessToken = ModalRoute.of(context)?.settings.arguments as String?;
          return MainPage(accessToken: accessToken!);
        },
        '/registration': (context) => RegistrationPage(),
        '/welcomepage': (context) => WelcomePage(),
        '/login': (context) => Login(), // Asumiendo que tienes una clase llamada Login para tu pantalla de inicio de sesión.
      },
    );
  }

}
