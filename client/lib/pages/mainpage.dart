import 'package:flutter/material.dart';
import 'account.dart';
import 'account_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Importa el paquete qr_flutter

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
  int? selectedAccountIndex;

  List<Account> accounts = [];

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
        title: Text('Mis Cuentas - ${userName ?? ''}'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedAccountIndex = index;
              });
            },
            child: Container(
              color: selectedAccountIndex == index ? Colors.blue : Colors.transparent, // Cambiar el color de fondo según si la cuenta está seleccionada o no
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: AccountCard(account: account),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Codi qr para cobrar'),
                            content: Container(
                              width: 200,
                              height: 200,
                              child: QrImageView(
                                data: 'Número de cuenta: ${account.numberAccount}',
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cerrar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.info_outline),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              //camara
            ),

            ElevatedButton(
              onPressed: selectedAccountIndex != null && accounts[selectedAccountIndex!].balance > 0 ? () {
                Navigator.pushNamed(
                  context,
                  '/paymentpage',
                  arguments: {'accountNumber': accounts[selectedAccountIndex!].numberAccount},
                );
              } : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return null; // Use the default color.
                    }
                    return Colors.green; // Use the green color when enabled.
                  },
                ),
              ),
              child: Text('A pagar'),
            ),

            ElevatedButton(
              onPressed: selectedAccountIndex != null ? () {
                Navigator.pushNamed(
                  context,
                  '/chargepage',
                  arguments: {'accountNumber': accounts[selectedAccountIndex!].numberAccount},
                );
              } : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return null; // Use the default color.
                    }
                    return Colors.green; // Use the green color when enabled.
                  },
                ),
              ),
              child: Text('A cobrar'),
            ),
          ],
        ),
      ),
    );
  }
}
