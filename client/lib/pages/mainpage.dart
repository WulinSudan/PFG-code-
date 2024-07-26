import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'account_card.dart';
import '../functions/fetchUserDate.dart';
import '../addAccount.dart';
import '../dialogs/logoutDialog.dart'; // Asegúrate de que esta ruta sea correcta
import '../dialogs/showDeletedConfirmationDialog.dart';

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

              Navigator.pushReplacementNamed(
                context,
                '/mainpage',
                arguments: widget.accessToken,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showLogoutConfirmationDialog(context);
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
        onPressed: () async {
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
                  arguments: {
                    'accessToken': widget.accessToken,
                    'account': accounts[selectedAccountIndex!],
                  },
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
                  arguments: {
                    'accessToken': widget.accessToken,
                    'accountNumber': accounts[selectedAccountIndex!].numberAccount
                  },
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
                  arguments: {
                    'accessToken': widget.accessToken,
                    'accountNumber': accounts[selectedAccountIndex!].numberAccount,
                  },
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
