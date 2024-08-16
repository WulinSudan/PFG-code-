import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'account_card.dart';
import '../functions/fetchUserData.dart';
import '../functions/addAccount.dart';
import '../functions/getAccountTransactions.dart';
import '../dialogs/logoutDialog.dart';
import '../dialogs/showDeletedConfirmationDialog.dart';
import '../utils/transaction_card.dart';
import '../utils/transaction.dart';
import 'color_selection_page.dart';
import 'package:client/functions/changeAccountStatus.dart';
import 'package:client/functions/getAccountStatus.dart';
import 'package:client/dialogs/confirmationOKdialog.dart';
import 'package:client/dialogs/askconfirmacion.dart';
import 'package:client/functions/removeUser.dart';
import 'login.dart'; // Asegúrate de importar la página de login si no lo has hecho

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
  List<Transaction> transactions = [];
  int? selectedAccountIndex;
  bool isCreatingAccount = false;
  Color appBarColor = Colors.redAccent;
  Color navigationDrawerColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    _loadAppBarColors();
    fetchData();
  }

  Future<void> _loadAppBarColors() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColor = prefs.getString('appBarColor') ?? '0xFFFF0000'; // Valor por defecto en hexadecimal
    final savedNavigationColor = prefs.getString('navigationDrawerColor') ?? '0xFFFF0000';
    setState(() {
      appBarColor = Color(int.parse(savedColor));
      navigationDrawerColor = Color(int.parse(savedNavigationColor));
    });
  }

  Future<void> _saveAppBarColors(Color appBarColor, Color navigationDrawerColor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appBarColor', '0x${appBarColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}');
    await prefs.setString('navigationDrawerColor', '0x${navigationDrawerColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}');
  }

  void _navigateToColorSelection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColorSelectionPage(
          onColorSelected: (color) {
            setState(() {
              appBarColor = color;
              navigationDrawerColor = color;
            });
            _saveAppBarColors(appBarColor, navigationDrawerColor);
          },
        ),
      ),
    );
  }

  Future<void> fetchData() async {
    await fetchUserData(widget.accessToken, updateUserData);
  }

  Future<void> updateUserData(String? name, String? id, List<dynamic> fetchedAccounts) async {
    setState(() {
      userName = name;
      dni = id;
      accounts = fetchedAccounts.map((accountData) => Account.fromJson(accountData)).toList();
    });

    print('UserName actualizado: $userName');
    print('DNI actualizado: $dni');
    print('Cuentas actualizadas: $accounts');
  }

  void _onAccountSelected(int index) async {
    setState(() {
      if (selectedAccountIndex == index) {
        selectedAccountIndex = null; // Deseleccionar si ya está seleccionado
      } else {
        selectedAccountIndex = index; // Seleccionar nueva cuenta
      }
    });

    if (selectedAccountIndex != null && selectedAccountIndex! < accounts.length) {
      final accountNumber = accounts[selectedAccountIndex!].numberAccount;
      try {
        final fetchedTransactions = await getAccountTransactions(widget.accessToken, accountNumber);
        setState(() {
          transactions = fetchedTransactions;
        });
      } catch (e) {
        print('Error al obtener transacciones: $e');
      }
    }
  }

  void _toggleAccountStatus() async {
    if (selectedAccountIndex != null && selectedAccountIndex! < accounts.length) {
      final account = accounts[selectedAccountIndex!];
      try {
        // Cambia el estado de la cuenta en el servidor
        bool status = await changeAccountStatus(widget.accessToken, account.numberAccount);

        setState(() {
          account.active = status; // Alternar el estado
        });

        showConfirmationOKDialog(context);
      } catch (e) {
        print('Error al cambiar el estado de la cuenta: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Mis Cuentas - ${userName ?? ''}'),
        centerTitle: true,
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: Icon(Icons.autorenew),
            onPressed: () async {
              await fetchData();
              setState(() {}); // Asegúrate de que la UI se actualice
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              if (!isCreatingAccount) {
                setState(() {
                  isCreatingAccount = true;
                });

                await addAccount(widget.accessToken);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cuenta añadida correctamente'),
                    duration: Duration(seconds: 3),
                  ),
                );

                await fetchData();

                setState(() {
                  isCreatingAccount = false;
                });
              }
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
                color: navigationDrawerColor, // Cambiar el color del Drawer
              ),
              child: Text('Navegación', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/settings',
                  arguments: widget.accessToken,
                );
              },
            ),
            ListTile(
              title: Text('Cambiar color de fondo'),
              onTap: _navigateToColorSelection,
            ),
            ListTile(
              title: Text('Eliminar el usuario'),
              onTap: () async {
                final deleteConfirmed = await askConfirmation(context);
                if (deleteConfirmed == true) {
                  await removeUser(context, widget.accessToken, dni!);
                  // Redirigir a la página de login después de la eliminación
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              height: 150.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return GestureDetector(
                    onTap: () {
                      _onAccountSelected(index);
                    },
                    child: Container(
                      width: 150.0,
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: selectedAccountIndex == index ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: AccountCard(account: account),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: selectedAccountIndex != null
                ? ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return TransactionCard(
                  transaction: transaction,
                );
              },
            )
                : Center(child: Text('Selecciona una cuenta')),
          ),
        ],
      ),
      bottomNavigationBar: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: selectedAccountIndex != null && selectedAccountIndex! < accounts.length && accounts[selectedAccountIndex!].balance > 0
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
                icon: Icon(
                  Icons.camera_alt_outlined,
                  color: selectedAccountIndex != null ? Colors.green : Colors.grey, // Cambiar color basado en selección
                  size: 40.0,
                ),
              ),
              SizedBox(width: 8.0), // Espaciado entre íconos
              IconButton(
                onPressed: selectedAccountIndex != null && selectedAccountIndex! < accounts.length && accounts[selectedAccountIndex!].balance > 0
                    ? () {
                  Navigator.pushNamed(
                    context,
                    '/paymentpage',
                    arguments: {
                      'accessToken': widget.accessToken,
                      'accountNumber': accounts[selectedAccountIndex!].numberAccount,
                    },
                  );
                }
                    : null,
                icon: Icon(
                  Icons.payment_outlined,
                  color: selectedAccountIndex != null ? Colors.red : Colors.grey, // Cambiar color basado en selección
                  size: 40.0,
                ),
              ),
              SizedBox(width: 8.0), // Espaciado entre íconos
              IconButton(
                onPressed: selectedAccountIndex != null && selectedAccountIndex! < accounts.length
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
                icon: Icon(
                  Icons.payment_outlined,
                  color: selectedAccountIndex != null ? Colors.green : Colors.grey, // Cambiar color basado en selección
                  size: 40.0,
                ),
              ),
              SizedBox(width: 8.0), // Espaciado entre íconos
              IconButton(
                onPressed: selectedAccountIndex != null && selectedAccountIndex! < accounts.length
                    ? () async {
                  await showDeleteConfirmationDialog(
                    context,
                    widget.accessToken,
                    accounts,
                    accounts[selectedAccountIndex!],
                  );
                  await fetchData();
                  setState(() {});
                }
                    : null,
                icon: Icon(
                  Icons.delete,
                  color: selectedAccountIndex != null ? Colors.red : Colors.grey, // Cambiar color basado en selección
                  size: 40.0,
                ),
              ),
              SizedBox(width: 8.0), // Espaciado entre íconos
              IconButton(
                onPressed: selectedAccountIndex != null && selectedAccountIndex! < accounts.length
                    ? () async {
                  _toggleAccountStatus();
                }
                    : null,
                icon: Icon(
                  accounts.isNotEmpty &&
                      selectedAccountIndex != null &&
                      selectedAccountIndex! < accounts.length &&
                      accounts[selectedAccountIndex!].active
                      ? Icons.lock
                      : Icons.lock_open,
                  color: selectedAccountIndex != null ? Colors.red : Colors.grey, // Cambiar color basado en selección
                  size: 40.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
