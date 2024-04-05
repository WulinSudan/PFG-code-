import 'package:flutter/material.dart';
import 'package:myapp/pages/account.dart';
import 'package:myapp/pages/account_card.dart';

class MainPage extends StatefulWidget {
  final String username;

  MainPage({required this.username});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Account> accounts = [
    Account(account_number: 12345678, name: 'Cuenta de Ahorro', balance: 5000, select: false),
    Account(account_number: 12344678, name: 'Cuenta Corriente', balance: 10000, select: false),
    Account(account_number: 12244678, name: 'Tarjeta de Crédito', balance: -2000, select: false),
  ];

  int selectedAccountIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Mis Cuentas - ${widget.username}'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          return AccountCard(
            account: accounts[index],
            isSelected: index == selectedAccountIndex,
            onSelect: (bool isSelected) {
              setState(() {
                // Si el botón se selecciona por primera vez
                if (isSelected) {
                  if (selectedAccountIndex == index) {
                    // Si el mismo botón se selecciona nuevamente, volver a la situación inicial
                    selectedAccountIndex = -1;
                  } else {
                    // Si otro botón se selecciona, actualizar el índice seleccionado
                    selectedAccountIndex = index;
                  }
                } else {
                  // Si el botón se deselecciona, volver a la situación inicial
                  selectedAccountIndex = -1;
                  isSelected = false;
                  print(selectedAccountIndex);
                }
              });
            },
          );
        },
      ),



      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min, // Ajustar el tamaño del Row al mínimo necesario
        children: [
          SizedBox(width: 8),
          Text(
            selectedAccountIndex == -1
                ? 'Seleccionar un compte per fer transferencia. '
                : 'La cuenta seleccionat. ',
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.grey[500],
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              // Acción para el botón flotante
              Navigator.pushNamed(context, '/qrmainpage');
            },
            child: Icon(Icons.compare_arrows),
            //backgroundColor: Colors.grey,
            backgroundColor: selectedAccountIndex == -1 ? Colors.grey : Colors.redAccent,
          ),
        ],
      ),



    );
  }
}
