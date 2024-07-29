import 'package:flutter/material.dart';

Future<double?> getImportDialog(BuildContext context) async {
  TextEditingController _controller = TextEditingController();

  return showDialog<double>(
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
              // Devolver el importe ingresado convertido a double
              final input = _controller.text;
              if (input.isNotEmpty) {
                Navigator.of(context).pop(double.tryParse(input));
              } else {
                Navigator.of(context).pop(); // Cerrar el diálogo sin devolver valor
              }
            },
          ),
        ],
      );
    },
  );
}
