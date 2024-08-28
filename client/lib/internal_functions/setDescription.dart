import 'package:client/dialogs_simples/errorDialog.dart';
import 'package:flutter/material.dart';
import 'package:client/dialogs/getDescriptionDialog.dart';
import 'package:client/functions/setAccountDescription.dart';

Future<void> setDescription(BuildContext context, String accessToken, String accountNumber, Future<void> Function() fetchData) async {
  Navigator.pop(context); // Cerrar el BottomSheet

  final description = await getDescriptionDialog(context); // Obtener la descripción

  if (description != null) {
    try {
      await setAccountDescription(accessToken, accountNumber, description); // Establecer la descripción
      await fetchData(); // Volver a cargar los datos después de establecer la descripción
    } catch (e) {
      errorDialog(context, "Error setting description"); // Mostrar error en caso de fallo
    }
  } else {
    errorDialog(context, "No valid description entered"); // Mostrar error si la descripción es inválida
  }

  await fetchData(); // Recargar los datos después de cualquier cambio
}
