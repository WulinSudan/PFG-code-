import 'package:flutter/material.dart';
import 'account.dart';
import 'account_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import '../functions/fetchUserDate.dart';
import '../functions/addAccount.dart';
import '../functions/removeAccount.dart';

class MainPage extends StatefulWidget {
  final String accessToken;

  MainPage({required this.accessToken});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? userName;
  String? dni;
  List<Account> accounts = [];
  int? selectedAccountIndex;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchUserData(widget.accessToken, updateUserData);
  }

  void updateUserData(String? name, String? id, List<dynamic> fetchedAccounts) {
    setState(() {
      userName = name;
      dni = id;
      accounts = fetchedAccounts.map((accountData) => Account.fromJson(accountData)).toList();
    });

    print('UserName actualizado: $userName');
    print('DNI actualizado: $dni');
    print('Cuentas actualizadas: $accounts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Mis Cuentas - ${userName ?? ''}'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await addAccount(widget.accessToken);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cuenta añadida correctamente'),
                  duration: Duration(seconds: 3),
                ),
              );

              Navigator.pushNamed(
                context,
                '/mainpage',
                arguments: widget.accessToken,
              );
            },

          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Navegación'),
            ),
            ListTile(
              title: Text('Opción 1'),
              onTap: () {
                // Implementa la navegación deseada
              },
            ),
            ListTile(
              title: Text('Opción 2'),
              onTap: () {
                // Implementa la navegación deseada
              },
            ),
            // Agrega más elementos de lista según sea necesario
          ],
        ),
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
              color: selectedAccountIndex == index ? Colors.blue : Colors.transparent,
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: AccountCard(account: account),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: selectedAccountIndex != null
          ? FloatingActionButton(
        onPressed: () async{
          await showDeleteConfirmationDialog(context, widget.accessToken, accounts, accounts[selectedAccountIndex!]);
          },

        tooltip: 'Eliminar cuenta',
        child: Icon(Icons.delete),
        backgroundColor: Colors.red,
      )
          : null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: selectedAccountIndex != null && accounts[selectedAccountIndex!].balance > 0
                  ? () {
                Navigator.pushNamed(
                  context,
                  '/qrscanner',
                );
              }
                  : null,
              child: Text('Camera'),
            ),
            ElevatedButton(
              onPressed: selectedAccountIndex != null && accounts[selectedAccountIndex!].balance > 0
                  ? () {
                Navigator.pushNamed(
                  context,
                  '/paymentpage',
                  arguments: {'accountNumber': accounts[selectedAccountIndex!].numberAccount},
                );
              }
                  : null,
              child: Text('A pagar'),
            ),
            ElevatedButton(
              onPressed: selectedAccountIndex != null
                  ? () {
                Navigator.pushNamed(
                  context,
                  '/chargepage',
                  arguments: {'accountNumber': accounts[selectedAccountIndex!].numberAccount},
                );
              }
                  : null,
              child: Text('A cobrar'),
            ),
          ],
        ),
      ),
    );
  }
}
