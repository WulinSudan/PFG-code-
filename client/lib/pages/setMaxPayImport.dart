import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'account_card2.dart';
import '../functions/fetchUserDate.dart'; // Asegúrate de que esta ruta sea correcta
import '../functions/addAccount.dart'; // Asegúrate de que esta ruta sea correcta
import '../dialogs/logoutDialog.dart'; // Asegúrate de que esta ruta sea correcta
import '../dialogs/showDeletedConfirmationDialog.dart'; // Asegúrate de que esta ruta sea correcta
import '../dialogs/showHelloDialog.dart'; // Asegúrate de que esta ruta sea correcta
import '../dialogs/getImportDialog.dart'; // Asegúrate de que esta ruta sea correcta
import '../functions/setNewMax.dart'; // Asegúrate de que esta ruta sea correcta
import '../dialogs/confirmationDialog.dart';
class SetMaxPayImport extends StatefulWidget {
  final String accessToken;

  SetMaxPayImport({required this.accessToken});

  @override
  State<SetMaxPayImport> createState() => SetMaxPayImportState();
}

class SetMaxPayImportState extends State<SetMaxPayImport> {
  String? userName;
  String? dni;
  List<Account> accounts = [];
  int? selectedAccountIndex; // Índice de la cuenta seleccionada

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      await fetchUserData(widget.accessToken, updateUserData);
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
    }
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

  void _onAccountSelected(int index) {
    setState(() {
      selectedAccountIndex = index;
    });
  }

  void _onConfigureMaxPay() async {
    // Lógica para configurar el maxPay por vez
    final selectedAccount = accounts[selectedAccountIndex!];
    print('Configurar maxPay para la cuenta ${selectedAccount.numberAccount}');

    // Llamada asincrónica para obtener el importe
    final import = await getImportDialog(context);

    // Verificar si se obtuvo un importe válido
    if (import != null) {
      // Lógica para usar el importe ingresado
      print('Importe ingresado: $import');

      try {
        await setNewMax(widget.accessToken, selectedAccount.numberAccount, import);
        print('MaxPay configurado exitosamente.');

        // Actualizar los datos después de configurar el máximo
        await fetchData(); // Actualiza los datos

      } catch (e) {
        print('Error al configurar MaxPay: $e');
      }
    } else {
      print('No se ingresó un importe válido.');
    }
  }

  void _onConfigureMaxPayDay() {
    // Lógica para configurar el maxPay diario
    final selectedAccount = accounts[selectedAccountIndex!];
    print('Configurar maxPay diario para la cuenta ${selectedAccount.numberAccount}');
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return GestureDetector(
                  onTap: () => _onAccountSelected(index),
                  child: Container(
                    color: selectedAccountIndex == index ? Colors.blue : Colors.transparent,
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AccountCard2(account: account),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedAccountIndex != null ? _onConfigureMaxPay : null,
                    child: Text('Configurar maxPay por vez'),
                  ),
                ),
                SizedBox(width: 16.0), // Espacio entre los botones
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedAccountIndex != null ? _onConfigureMaxPayDay : null,
                    child: Text('Configurar maxPay diario'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
