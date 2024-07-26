import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar Logout'),
        content: Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada más
            },
          ),
          TextButton(
            child: Text('Salir'),
            onPressed: () async {
              // Elimina el token de SharedPreferences
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('access_token');

              // Cierra el diálogo
              Navigator.of(context).pop();

              // Redirige al usuario a la página de inicio de sesión
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      );
    },
  );
}
