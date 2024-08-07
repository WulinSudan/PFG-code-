import 'package:flutter/material.dart';
import 'dart:async';

Future<void> showConfirmationOKDialog(BuildContext context) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // Evita que el diálogo se cierre al tocar fuera de él
    builder: (BuildContext context) {
      // Programa el cierre automático del diálogo después de 2 segundos
      Timer(Duration(seconds: 2), () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });

      return AlertDialog(
        title: Text('Confirmación'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.check_circle,
              color: Colors.green, // Puedes cambiar el color del ícono
              size: 40.0, // Tamaño del ícono
            ),
            SizedBox(width: 16.0), // Espacio entre el ícono y el texto
            Expanded(
              child: Text(
                '',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      );
    },
  );
}
