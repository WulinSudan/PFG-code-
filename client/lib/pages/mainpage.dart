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

  List<Account> accounts = [
    Account(account_number: 12345678, name: 'Cuenta de Ahorro', balance: 5000, select: false),
    Account(account_number: 12344678, name: 'Cuenta Corriente', balance: 10000, select: false),
    Account(account_number: 12244678, name: 'Tarjeta de Crédito', balance: -2000, select: false),
  ];

  int selectedAccountIndex = -1;

  @override
  void initState() {
    super.initState();
    // Llamar a una consulta GraphQL para obtener el nombre del usuario
    fetchUserName();
  }

  Future<void> fetchUserName() async {
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
        title: Text('Mis Cuentas - ${userName ?? ''}'), // Mostrar el nombre del usuario
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                return AccountCard(
                  account: accounts[index],
                  isSelected: index == selectedAccountIndex,
                  onSelect: (bool isSelected) {
                    setState(() {
                      if (isSelected) {
                        if (selectedAccountIndex == index) {
                          selectedAccountIndex = -1;
                        } else {
                          selectedAccountIndex = index;
                        }
                      } else {
                        selectedAccountIndex = -1;
                        isSelected = false;
                        print(selectedAccountIndex);
                      }
                    });
                  },
                );
              },
            ),
            SizedBox(height: 100), // Espacio adicional al final para evitar que el contenido se superponga con el FloatingActionButton
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 8),
          Text(
            selectedAccountIndex == -1
                ? 'Seleccionar una cuenta para hacer una transferencia.'
                : 'La cuenta seleccionada.',
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.grey[500],
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/qrmainpage');
            },
            child: Icon(Icons.compare_arrows),
            backgroundColor: selectedAccountIndex == -1 ? Colors.grey : Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
