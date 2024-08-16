import 'package:flutter/material.dart';

Future<bool?> askConfirmation(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmación'),
        content: Text('¿Seguro que quieres realizar esta operación?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Retorna 'false' al cancelar
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Retorna 'true' al aceptar
            },
            child: Text('Aceptar'),
          ),
        ],
      );
    },
  );
}
