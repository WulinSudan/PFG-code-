import 'package:flutter/material.dart';

Future<String?> showImporteDialog(BuildContext context) async {
  TextEditingController _controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Ingrese el Importe'),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ingrese un número',
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo sin devolver valor
            },
          ),
          TextButton(
            child: Text('Aceptar'),
            onPressed: () {
              Navigator.of(context).pop(_controller.text); // Devolver el importe ingresado
            },
          ),
        ],
      );
    },
  );
}
