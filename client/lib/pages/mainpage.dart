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
  Future<void> showDeleteConfirmationDialog(BuildContext context, List<Account> accounts, Account selectedAccount) async {
    if (selectedAccount.balance == 0) {
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
                  removeAccount(selectedAccount.numberAccount);
                },
              ),
            ],
          );
        },
      );
    } else {
      showTransferDialog(context,selectedAccount);
    }
  }


  //per eliminar un compte, segon pas
  Future<void> showTransferDialog(BuildContext context, Account currentAccount) async {
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
                selectAccountDialog(context, accounts, currentAccount);
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

  Future<void> selectAccountDialog(BuildContext context, List<Account> accounts, Account currentAccount) async {
    // Filtrar las cuentas excluyendo la cuenta actual
    List<Account> filteredAccounts = accounts.where((account) => account.numberAccount != currentAccount.numberAccount).toList();

    // Variable para guardar la cuenta seleccionada
    Account? selectedAccount;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Seleccionar una cuenta para vaciar el saldo'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: filteredAccounts.map((account) {
                    return ListTile(
                      title: Text('${account.numberAccount} - Saldo: ${account.balance.toStringAsFixed(2)}'),
                      tileColor: selectedAccount == account ? Colors.blue.withOpacity(0.5) : null,
                      onTap: () {
                        setState(() {
                          selectedAccount = account;
                        });
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
                TextButton(
                  child: Text('Aceptar'),
                  onPressed: selectedAccount != null
                      ? () {
                    if (selectedAccount != null) {
                      Navigator.of(context).pop();
                      makeTransfer(context, currentAccount,selectedAccount!);

                    }
                  }
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: selectedAccount != null ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> makeTransfer(BuildContext context, Account currentAccount, Account selectedAccount) async {
    print(currentAccount.numberAccount);
    print(selectedAccount.numberAccount);
    print(currentAccount.balance);

    final GraphQLClient client = GraphQLService.createGraphQLClient(widget.accessToken);

    try {
      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(makeTransferMutation),
          variables: {
            'input': {
              'accountOrigen': currentAccount.numberAccount,
              'accountDestin': selectedAccount.numberAccount,
              'import': currentAccount.balance,
            }
          },
        ),
      );

      if (result.hasException) {
        print('Error al ejecutar la mutación: ${result.exception.toString()}');
      } else {
        print('Mutación exitosa');

        removeAccount(currentAccount.numberAccount);

        // Mostrar el diálogo
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Cuenta eliminada'),
              content: Text('Se ha eliminado correctamente la cuenta.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      '/mainpage',
                      arguments: widget.accessToken,
                    );
                  },
                ),
              ],
            );
          },
        );

        Navigator.pushNamed(
          context,
          '/mainpage',
          arguments: widget.accessToken,
        );
        // Aquí puedes manejar la respuesta de la mutación si es necesario
        // Por ejemplo, podrías actualizar las cuentas llamando a fetchUserAccounts()
        // O realizar alguna otra acción según tus necesidades
      }
    } catch (e) {
      print('Error inesperado: $e');
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
          showDeleteConfirmationDialog(context, accounts,accounts[selectedAccountIndex!]);
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
