import 'package:flutter/material.dart';
import 'pages/welcomepage.dart';
import 'pages/login.dart';
import 'pages/mainpage.dart';
import 'mutation.dart';
import 'pages/chargepage.dart';
import 'pages/paymentpage.dart';
import 'pages/qrscanner.dart';
import 'pages/qrgestion.dart';
import 'utils/account.dart';
import 'pages/admin.dart';
import 'pages/registrationAdmin.dart';
import 'pages/allAdmins.dart';
import 'pages/registrationUser.dart';

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
      initialRoute: '/welcomepage',
      routes: {
        '/admin': (context) {
          final String? accessToken = ModalRoute.of(context)?.settings.arguments as String?;
          return AdminPage(accessToken: accessToken!);
        },
        '/allAdmins': (context) => AllAdminsPage(accessToken: ModalRoute.of(context)!.settings.arguments as String),
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
        '/registrationAdmin': (context) => RegistrationAdminPage(),
        '/registrationUser': (context) => RegistrationUserPage(),
        '/welcomepage': (context) => WelcomePage(),
        '/login': (context) => Login(), // Asumiendo que tienes una clase llamada Login para tu pantalla de inicio de sesión.
      },
    );
  }

}
