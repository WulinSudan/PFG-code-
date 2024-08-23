import 'package:flutter/material.dart';
import '../utils/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final bool isSelected; // Agregar esta propiedad para saber si el card está seleccionado

  const UserCard({Key? key, required this.user, this.isSelected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? Colors.blueAccent : Colors.transparent, // Cambia el color del borde basado en la selección
          width: 2.0, // Grosor del borde
        ),
        borderRadius: BorderRadius.circular(8.0), // Radio de las esquinas
      ),
      child: ListTile(
        title: Text('User name: ${user.name}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DNI: ${user.dni}'),
            Text('Active: ${user.active}')
          ],
        ),
      ),
    );
  }
}
