import 'package:flutter/material.dart';

Future<void> showAddUserAdminDialog(BuildContext context, String accessToken) async {
  bool isAdmin = false;
  bool optionSelected = false; // Variable para saber si se ha seleccionado una opción

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Seleccionar tipo de usuario'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAdmin = false;
                      optionSelected = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(
                      color: !isAdmin && optionSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text('Agregar Usuario'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAdmin = true;
                      optionSelected = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(
                      color: isAdmin && optionSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text('Agregar Administrador'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: optionSelected
                    ? () {
                  Navigator.of(context).pop(); // Cierra el diálogo primero

                  Navigator.pushNamed(
                    context,
                    isAdmin ? '/registrationAdmin' : '/registrationUser',
                    arguments: accessToken,
                  );
                }
                    : null, // Desactiva el botón si no se ha seleccionado una opción
                child: Text('Agregar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
    },
  );
}
