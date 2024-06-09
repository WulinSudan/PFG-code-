import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart'; // Asegúrate de tener esta dependencia
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';

class QrMainPage extends StatefulWidget {

  final String accessToken;
  QrMainPage({required this.accessToken});

  @override
  _QrMainPageState createState() => _QrMainPageState();
}

class _QrMainPageState extends State<QrMainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Mis Cuentas'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
