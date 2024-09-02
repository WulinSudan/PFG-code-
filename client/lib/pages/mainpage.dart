import 'package:client/dialogs_simples/errorDialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/functions/changeAccountStatus.dart';
import 'package:client/functions/getUserStatusDni.dart';
import 'package:client/functions/fetchUserData.dart';
import 'package:client/functions/addAccount.dart';
import 'package:client/functions/getAccountTransactions.dart';
import 'package:client/dialogs/logoutDialog.dart';
import 'package:client/dialogs/showDeletedConfirmationDialog.dart';
import 'package:client/utils/transaction_card.dart';
import 'package:client/utils/transaction.dart';
import 'package:client/dialogs_simples/okDialog.dart';
import 'package:client/dialogs_simples/askconfirmacion.dart';
import 'package:client/functions/removeUser.dart';
import 'package:client/dialogs/changePasswordDialog.dart';
import 'package:client/dialogs/manualTransfer.dart';
import 'color_selection_page.dart';
import '../utils/account.dart';
import '../utils/account_card.dart';
import '../functions/changeUserStatus.dart';
import '../internal_functions/setDescription.dart';
import '../internal_functions/setMaxImport.dart';
import '../internal_functions/ViewAndChangeUserStatus.dart';

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
  bool _userStatus = true;

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

    // Fetch user status
    if (dni != null) {
      bool userStatus = await getUserStatusDni(widget.accessToken, dni!);
      setState(() {
        _userStatus = userStatus; // Almacenar el estado del usuario
      });
    }
  }

  Future<void> updateUserData(String? name, String? id, List<dynamic> fetchedAccounts) async {
    setState(() {
      userName = name;
      dni = id;
      accounts = fetchedAccounts.map((accountData) => Account.fromJson(accountData)).toList();
    });

  }

  void _onAccountSelected(int index) async {
    fetchData();

    print("------------------------------------------");
    print(_userStatus);
    print("------------------------------------------");

    if (!_userStatus) {
      errorDialog(context, "User is inactive. You cannot select accounts.");
      return;
    }

    if (index >= 0 && index < accounts.length) {
      setState(() {
        if (selectedAccountIndex == index) {
          selectedAccountIndex = null; // Deseleccionar si ya está seleccionado
        } else {
          selectedAccountIndex = index; // Seleccionar nueva cuenta
        }
      });

      if (selectedAccountIndex != null) {
        final accountNumber = accounts[selectedAccountIndex!].numberAccount;
        try {
          final fetchedTransactions = await getAccountTransactions(widget.accessToken, accountNumber);
          setState(() {
            transactions = fetchedTransactions;
          });
        } catch (e) {
          errorDialog(context, "Error getting transactions");
        }
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

        okDialog(context, "Status changed");
      } catch (e) {
        errorDialog(context, "Error changing status");

      }
    }
  }

  bool get hasSelectedAccount {
    return selectedAccountIndex != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('WelCome - ${userName ?? ''}'),
        centerTitle: true,
        backgroundColor: appBarColor,
        actions: _userStatus ? [
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
                okDialog(context,"Account added successfully");

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
        ] : [],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: navigationDrawerColor,
              ),
              child: Text('Navigation', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text('Change password'),
              onTap: _userStatus ? () {
                showChangePasswordDialog(context, widget.accessToken);
              } : null,
            ),
            ListTile(
              title: Text('Change color'),
              onTap: _userStatus ? _navigateToColorSelection : null,
            ),
            ListTile(
              title: Text('Change user status'),
              onTap: () async {
                selectedAccountIndex = null;
                await showUserStatusDialog(context, widget.accessToken, dni, fetchData);
              },
            ),
            ListTile(
              title: Text('Remove user'),
              onTap: _userStatus ? () async {
                final deleteConfirmed = await askConfirmation(context);
                if (deleteConfirmed == true) {
                  if (dni != null) {
                    await removeUser(context, widget.accessToken, dni!);

                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }
              } : null, // Deshabilitar si el usuario no está activo

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
                : Center(child: Text('Select an account')),
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
                onPressed: hasSelectedAccount
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
                  color: hasSelectedAccount ? Colors.green : Colors.grey,
                  size: 40.0,
                ),
              ),
              SizedBox(width: 8.0), // Espaciado entre íconos
              IconButton(
                onPressed: accounts.isNotEmpty && selectedAccountIndex != null && accounts[selectedAccountIndex!].active
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
                  color: accounts.isNotEmpty && selectedAccountIndex != null && accounts[selectedAccountIndex!].active ? Colors.red : Colors.grey,
                  size: 40.0,
                ),
              ),


              SizedBox(width: 8.0), // Espaciado entre íconos
              IconButton(
                onPressed: hasSelectedAccount
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
                  color: hasSelectedAccount ? Colors.green : Colors.grey,
                  size: 40.0,
                ),
              ),



              SizedBox(width: 8.0),
              IconButton(
                onPressed: hasSelectedAccount
                    ? () async {
                  await showDeleteConfirmationDialog(
                    context,
                    widget.accessToken,
                    accounts,
                    accounts[selectedAccountIndex!],
                    fetchData,
                  );
                  selectedAccountIndex = null;
                  await fetchData();
                  setState(() {});
                }
                    : null,
                icon: Icon(
                  Icons.delete,
                  color: hasSelectedAccount ? Colors.red : Colors.grey,
                  size: 40.0,
                ),
              ),




              SizedBox(width: 8.0), // Espaciado entre íconos
              IconButton(
                onPressed: hasSelectedAccount
                    ? () async {
                  _toggleAccountStatus();
                }
                    : null,
                icon: Icon(
                  accounts.isNotEmpty && selectedAccountIndex != null && accounts[selectedAccountIndex!].active
                      ? Icons.lock
                      : Icons.lock_open,
                  color: hasSelectedAccount ? Colors.red : Colors.grey,
                  size: 40.0,
                ),
              ),
              SizedBox(width: 8.0), // Espaciado entre íconos
              IconButton(
                onPressed: hasSelectedAccount
                    ? () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text('Make transfer manually'),
                            onTap: () async {
                              Navigator.pop(context); // Cerrar el BottomSheet
                              await showManualTransferDialog(context, widget.accessToken, accounts[selectedAccountIndex!]);
                              await fetchData();
                              setState(() {});
                            },
                          ),
                          ListTile(
                            title: Text('Set max import pay day'),
                            onTap: () async {
                              if (selectedAccountIndex != null) {
                                await setMaxImport(context, widget.accessToken, accounts[selectedAccountIndex!].numberAccount, fetchData,);
                              }
                              setState(() {}); // Actualizar el estado después de cambiar el importe máximo
                            },
                          ),

                          ListTile(
                            title: Text('Set description'),
                            onTap: () async {
                              if (selectedAccountIndex != null) {
                                await setDescription(context, widget.accessToken, accounts[selectedAccountIndex!].numberAccount, fetchData,);
                              }
                              setState(() {}); // Actualizar el estado después de cambiar la descripción
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
                    : null,
                icon: Icon(
                  Icons.pending_outlined,
                  color: hasSelectedAccount ? Colors.green : Colors.grey,
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
