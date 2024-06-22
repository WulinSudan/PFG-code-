import 'dart:async';

import 'package:flutter/material.dart';
import 'account.dart';
import 'account_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Importa el paquete qr_flutter
import '../functions/fetchUserDate.dart';
import '../functions/addAccount.dart';


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


  Future<void> removeAccount(String accountNumber) async {
    final GraphQLClient client = GraphQLService.createGraphQLClient(widget.accessToken);

    try {
      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(removeAccountMutation),
          variables: {
            'number_account': accountNumber,
          },
        ),
      );

      if (result.hasException) {
        print('Error al ejecutar la mutación: ${result.exception.toString()}');
      } else {
        Navigator.pushNamed(
          context,
          '/mainpage',
          arguments: widget.accessToken,
        );
      }
    } catch (e) {
      print('Error inesperado: $e');
    }
  }


  //per eliminar un compte, primer pas
  Future<void> showDeleteConfirmationDialog(BuildContext context, List<Account> accounts, String accountNumber, double balance) async {
    if (balance == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmar eliminación'),
            content: Text('¿Estás seguro de que quieres eliminar esta cuenta?'),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Eliminar'),
                onPressed: () {
                  Navigator.of(context).pop();
                  removeAccount(accountNumber);
                },
              ),
            ],
          );
        },
      );
    } else {
      showTransferDialog(context,accountNumber);
    }
  }


  //per eliminar un compte, segon pas
  Future<void> showTransferDialog(BuildContext context, String accountNumber) async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Queda saldo, Transferencia entre cuentas propias'),
          content: Text('¿Qué deseas hacer?'),
          actions: <Widget>[
            TextButton(
              child: Text('Hacer transferencia'),
              onPressed: () {
                Navigator.of(context).pop('transfer');
                //selectAccoutDialog(context,accounts,accountNumber);
                selectAccountDialog(context, accounts, accountNumber);
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop('cancel');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> selectAccountDialog(BuildContext context, List<Account> accounts, String currentAccount) async {
    // Filtrar las cuentas excluyendo la cuenta actual
    List<Account> filteredAccounts = accounts.where((account) => account.numberAccount != currentAccount).toList();

    // Mostrar el AlertDialog con el listado de cuentas
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar una cuenta para vaciar el saldo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: filteredAccounts.map((account) {
                return ListTile(
                  title: Text('${account.numberAccount} - Saldo: ${account.balance.toStringAsFixed(2)}'),
                  onTap: () {
                    // Acción al seleccionar una cuenta
                    Navigator.of(context).pop();
                    showSnackbar(context);
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showSnackbar(BuildContext context) {
    // Crear un OverlayEntry personalizado
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: BorderRadius.circular(8.0),
            ),
            width: 400.0,
            height: 160.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Esta es una Snackbar',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      ),
    );

    // Mostrar el OverlayEntry en el contexto actual
    Overlay.of(context)?.insert(overlayEntry);

    // Cerrar la Snackbar después de 3 segundos
    Timer(Duration(seconds: 5), () {
      overlayEntry.remove();
    });
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
            onPressed: () {
              addAccount(widget.accessToken);
              Navigator.pushNamed(
                context,
                '/mainpage',
                arguments: widget.accessToken,
              );

            },
            tooltip: 'Añadir nueva cuenta',
          ),
        ],
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
        onPressed: () {
          showDeleteConfirmationDialog(context, accounts,accounts[selectedAccountIndex!].numberAccount, accounts[selectedAccountIndex!].balance);
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
  /*

  Future<void> addAccount() async {
    final GraphQLClient client = GraphQLService.createGraphQLClient(widget.accessToken);

    try {
      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(addAccountMutation),
        ),
      );

      if (result.hasException) {
        print('Error al ejecutar la mutación: ${result.exception.toString()}');
      } else {
        setState(() {
          // Aquí deberías manejar la respuesta de la mutación si es necesario
          // Por ejemplo, podrías actualizar las cuentas llamando a fetchUserAccounts()
          print('Mutación exitosa');

          Navigator.pushNamed(
            context,
            '/mainpage',
            arguments: widget.accessToken,
          );

        });
      }
    } catch (e) {
      print('Error inesperado: $e');
    }
  }*/
}
