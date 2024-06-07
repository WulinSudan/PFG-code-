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
  List<dynamic> list_accounts = [];
  int? contador = 1;


  List<Account> accounts = [
    Account(ownerDni: '123456789A', ownerName: 'Juan Pérez', numberAccount: '123456', balance: 1000, active: true),
    Account(ownerDni: '987654321B', ownerName: 'María López', numberAccount: '654321', balance: 2000, active: false),
    // Agrega más cuentas si es necesario
  ];

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

    for (var accountJson in list_accounts) {
      accounts.add(Account.fromJson(accountJson));
    }
    print("---------------------48------------------------");
    print(accounts.length);


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
    try {
      final GraphQLClient client = GraphQLService.createGraphQLClient(widget.accessToken);
      print('Fetching accounts for DNI: $dni');

      // Define query options with variables
      final QueryOptions options = QueryOptions(
        document: gql(getAccountsQuery),
        variables: <String, dynamic>{
          'dni': dni,
        },
      );

      // Perform the query
      final QueryResult result = await client.query(options);

      if (result.hasException) {
        print("Error al obtener las cuentas del usuario: ${result.exception}");
      } else if (result.data != null && result.data!['getUserAccountsInfoByDni'] != null) {
        setState(() {
          // Parse the accounts list
          list_accounts = List<dynamic>.from(result.data!['getUserAccountsInfoByDni']);
          contador = list_accounts.length;

          // Print account balances
          for (var account in list_accounts) {
            print('Cuenta ID: ${account['number_account']}, Saldo: ${account['balance']}');
          }
        });
      }
    } catch (e) {
      print('Ocurrió un error inesperado: $e');
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
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          return accountCard(account);
        },
      ),
    );
  }
}
