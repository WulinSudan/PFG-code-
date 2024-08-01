import 'package:flutter/material.dart';
import 'dart:async';

Future<void> errorConnectionDialog(BuildContext context) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // Evita que el diálogo se cierre al tocar fuera de él
    builder: (BuildContext context) {
      // Programa el cierre automático del diálogo después de 1 segundo
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });

      return AlertDialog(
        title: Text('Identificando...'),
        content: Text('Usuario o contrasña invalida'),
      );
    },
  );
}
