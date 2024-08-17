import 'package:flutter/material.dart';
import 'package:client/functions/changePassword.dart';
import 'package:client/dialogs/confirmationOKdialog.dart';


Future<void> showChangePasswordDialog(BuildContext context, String accessToken) async {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Evita que el diálogo se cierre al tocar fuera de él
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Cambiar Contraseña'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña Antigua'),
              ),
              SizedBox(height: 16),
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
              final oldPassword = oldPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmNewPassword = confirmNewPasswordController.text;

              if (newPassword != confirmNewPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Las contraseñas no coinciden')),
                );
                return;
              }

              try {
                final success = await changePassword(accessToken, oldPassword, newPassword);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contraseña cambiada con éxito')),
                  );
                  Navigator.of(context).pop(); // Cierra el diálogo

                  showConfirmationOKDialog(context);
                  // Redirige a la página de inicio de sesión
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login', // Nombre de la ruta para la página de inicio de sesión
                        (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
                  );
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
