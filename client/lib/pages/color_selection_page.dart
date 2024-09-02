import 'package:flutter/material.dart';

class ColorSelectionPage extends StatelessWidget {
  final ValueChanged<Color> onColorSelected;

  ColorSelectionPage({required this.onColorSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select color'),
        backgroundColor: Colors.redAccent,
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: Colors.primaries.length,
        itemBuilder: (context, index) {
          final color = Colors.primaries[index];
          return GestureDetector(
            onTap: () {
              onColorSelected(color); // Callback con el color seleccionado
              Navigator.of(context).pop(); // Volver a la página anterior
            },
            child: Container(
              color: color,
              margin: EdgeInsets.all(4.0),
            ),
          );
        },
      ),
    );
  }
}
