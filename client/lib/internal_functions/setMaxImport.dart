import 'package:client/dialogs_simples/errorDialog.dart';
import 'package:flutter/material.dart';
import 'package:client/functions/setNewMax.dart';
import 'package:client/dialogs/getImportDialog.dart';


Future<void> setMaxImport(BuildContext context, String accessToken, String accountNumber, Future<void> Function() fetchData) async {
  Navigator.pop(context); // Cerrar el BottomSheet

  final import = await getImportDialog(context); // Obtener el importe

  if (import != null) {
    try {
      await setNewMax(accessToken, accountNumber, import); // Establecer el nuevo importe máximo
      await fetchData(); // Volver a cargar los datos después de establecer el máximo
    } catch (e) {
      errorDialog(context, "Error setting up MaxPay"); // Mostrar error en caso de fallo
    }
  } else {
    errorDialog(context, "No valid amount is entered"); // Mostrar error si el importe es inválido
  }

  await fetchData(); // Recargar los datos después de cualquier cambio
}
