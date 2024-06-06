import 'package:flutter/material.dart';
import 'account.dart';
import 'account_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';

class MainPage extends StatefulWidget {
  final String accessToken;

  MainPage({required this.accessToken});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? userName;
  String? dni;
  // List<Account> list_accounts = [];
  List<dynamic> list_accounts = [];
  int? contador = 1;

  @override
  void initState() {
    super.initState();
    // Llamar a una consulta GraphQL para obtener el nombre, dni y cuentas del usuario
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    await fetchUserInfo();
    await fetchUserAccounts();

    print(userName);
    print(dni);
    print(list_accounts.length);

  }

  Future<void> fetchUserInfo() async {
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
        dni = result.data!['me']['dni'];
      });
    }
  }

  Future<void> fetchUserAccounts() async {
    final GraphQLClient client = GraphQLService.createGraphQLClient(widget.accessToken);
    print(dni);
    final QueryOptions options = QueryOptions(
      document: gql(getAccountsQuery),
      variables: <String, dynamic>{
        'dni': dni,
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print("Error al obtener las cuentas del usuario: ${result.exception}");
    } else if (result.data != null && result.data!['getUserAccountsInfoByDni'] != null) {
      setState(() {
        list_accounts = List<dynamic>.from(result.data!['getUserAccountsInfoByDni']);
        contador = list_accounts.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Mis Cuentas - ${userName ?? ''}'), // Mostrar el nombre del usuario
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total de cuentas del usuario: ${contador ?? 0}'),
            SizedBox(height: 8),
            Text('Nombre de usuario: ${userName ?? ''}'),
            SizedBox(height: 8),
            Text('DNI: ${dni ?? ''}'),
            // Puedes agregar más widgets aquí si lo necesitas
          ],
        ),
      ),
    );
  }
}
