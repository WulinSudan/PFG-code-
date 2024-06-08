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
  String userName = "";

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    // Aquí debes realizar tu consulta GraphQL para obtener el nombre del usuario
    final GraphQLClient client = GraphQLService.createGraphQLClient(widget.accessToken);

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(meQuery),
      ),
    );

    if (result.hasException) {
      print("Error al obtener el nombre del usuario: ${result.exception}");
    } else {
      setState(() {
        userName = result.data!['me']['name'];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Mis Cuentas - $userName'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 30.0),
            Image(
              image: AssetImage('assets/qr.png'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/qrscannerpage');
              },
              child: Text(
                'Cámara',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/qrpayment');
              },
              child: Text(
                'Generar QR pagament',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
