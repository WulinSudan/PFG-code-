import 'package:flutter/material.dart';

Future<String?> getDescriptionDialog(BuildContext context) async {
  print("En la funcion de getDescriptionDialog-----------");
  TextEditingController _controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Ingrese la descripción'),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Ingrese una descripción',
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
              final input = _controller.text;
              Navigator.of(context).pop(input.isNotEmpty ? input : null);
            },
          ),
        ],
      );
    },
  );
}
