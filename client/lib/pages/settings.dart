import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'account_card2.dart';
import '../functions/fetchUserDate.dart'; // Asegúrate de que esta ruta sea correcta
import '../functions/setAccountDescription.dart'; // Asegúrate de que esta ruta sea correcta
import '../functions/setNewMax.dart'; // Asegúrate de que esta ruta sea correcta
import '../dialogs/getDescriptionDialog.dart'; // Asegúrate de que esta ruta sea correcta
import '../dialogs/getImportDialog.dart'; // Asegúrate de que esta ruta sea correcta

class Settings extends StatefulWidget {
  final String accessToken;

  Settings({required this.accessToken});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? userName;
  String? dni;
  List<Account> accounts = [];
  int? selectedAccountIndex; // Índice de la cuenta seleccionada
  Color appBarColor = Colors.redAccent; // Color por defecto

  @override
  void initState() {
    super.initState();
    _loadAppBarColor();
    fetchData();
  }

  Future<void> _loadAppBarColor() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColor = prefs.getString('appBarColor') ?? '#FF0000'; // Valor por defecto en hexadecimal
    setState(() {
      appBarColor = Color(int.parse(savedColor, radix: 16) + 0xFF000000); // Convertir a ARGB
    });
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

  Future<void> _onConfigureMaxPay() async {
    final selectedAccount = accounts[selectedAccountIndex!];
    print('Configurar maxPay para la cuenta ${selectedAccount.numberAccount}');

    // Llamada asincrónica para obtener el importe
    final import = await getImportDialog(context);

    // Verificar si se obtuvo un importe válido
    if (import != null) {
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

  Future<void> _onConfigureDescription() async {
    final selectedAccount = accounts[selectedAccountIndex!];
    print('Configurar descripción para la cuenta ${selectedAccount.numberAccount}');

    // Llamada asincrónica para obtener la descripción
    final description = await getDescriptionDialog(context);

    // Verificar si se obtuvo una descripción válida
    if (description != null) {
      print('Descripción ingresada: $description');
      try {
        await setAccountDescription(widget.accessToken, selectedAccount.numberAccount, description);
        print('Descripción configurada exitosamente.');

        // Actualizar los datos después de configurar la descripción
        await fetchData(); // Actualiza los datos

      } catch (e) {
        print('Error al configurar la descripción: $e');
      }
    } else {
      print('No se ingresó una descripción válida.');
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
                    onPressed: selectedAccountIndex != null ? _onConfigureDescription : null,
                    child: Text('Configurar Descripción'),
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
