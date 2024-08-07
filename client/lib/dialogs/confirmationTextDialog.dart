import 'package:flutter/material.dart';
import 'dart:async';

Future<void> showConfirmationTextDialog(BuildContext context, String text) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // Evita que el diálogo se cierre al tocar fuera de él
    builder: (BuildContext context) {
      // Crea una variable para almacenar el Timer
      Timer? timer;

      // Programa el cierre automático del diálogo después de 2 segundos
      timer = Timer(Duration(seconds: 2), () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });

      // Asegúrate de cancelar el Timer cuando el diálogo se cierre manualmente
      return AlertDialog(
        title: Text('Confirmación'),
        content: Text(text), // Usa el texto dinámico
        actions: <Widget>[
          TextButton(
            onPressed: () {
              timer?.cancel(); // Cancela el Timer si se cierra manualmente
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
