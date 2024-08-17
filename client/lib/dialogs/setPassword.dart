import 'package:flutter/material.dart';
import 'package:client/functions/setPassword.dart';  // Asumiendo que has renombrado la función a `setPassword`
import 'package:client/dialogs/confirmationOKdialog.dart';

Future<void> showSetPasswordDialog(BuildContext context, String accessToken, String dni) async {
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Evita que el diálogo se cierre al tocar fuera de él
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Set password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Nueva Contraseña'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: confirmNewPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirmar Nueva Contraseña'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo sin hacer cambios
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPassword = newPasswordController.text;
              final confirmNewPassword = confirmNewPasswordController.text;

              if (newPassword != confirmNewPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Las contraseñas no coinciden')),
                );
                return;
              }

              try {
                final success = await setPassword(accessToken, newPassword, dni);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contraseña cambiada con éxito')),
                  );

                  showConfirmationOKDialog(context); // Mostrar el diálogo de confirmación

                  Navigator.of(context).pop(); // Cierra el diálogo


                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo cambiar la contraseña')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cambiar la contraseña: $e')),
                );
              }
            },
            child: Text('Cambiar'),
          ),
        ],
      );
    },
  );
}
