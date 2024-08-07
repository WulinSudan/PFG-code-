import 'package:flutter/material.dart';
import 'dart:async';

Future<void> showConfirmationDialog2(BuildContext context, String name, bool status) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Evita que el diálogo se cierre al tocar fuera de él
    builder: (BuildContext context) {
      // Programa el cierre automático del diálogo después de 2 segundos
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });

      return AlertDialog(
        title: Text('Confirmación'),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'El usuario ',
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
              TextSpan(
                text: name,
                style: TextStyle(color: Colors.black87, fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ' tiene la activación en ',
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
              TextSpan(
                text: status ? 'activo' : 'inactivo',
                style: TextStyle(color: status ? Colors.green[700] : Colors.red[700], fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '.',
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
    },
  );
}
