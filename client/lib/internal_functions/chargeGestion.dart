import 'package:flutter/material.dart';
import '../functions/doQr.dart'; // Asegúrate de que la ruta sea correcta
import '../dialogs/getImportDialog.dart'; // Asegúrate de que la ruta sea correcta
import '../dialogs/logoutDialog.dart';
import '../dialogs/confirmationDialog.dart';
import '../functions/addTransaction.dart';

Future<void> processQrCharge(
    BuildContext context,
    String qrText,
    Map<String, dynamic>? arguments,
    String accessToken,
    Function(String, String, double, String, bool) updateState,
    ) async {
  try {
    print('Iniciando processQrCharge con qrText: $qrText');
    String remainingText = qrText.substring("charge".length).trim();
    List<String> parts = remainingText.split(' ');
    if (parts.length == 2) {
      String accountNumber = parts[0];
      double? amount = double.tryParse(parts[1]);

      if (amount == null || amount <= 0) {
        amount = await getImportDialog(context) ?? 0.0;
        await showConfirmationDialog(context);
        print("En la pagina de chargeGestion.dart, el importe recogido: ${amount}");
      } else {
        await showConfirmationDialog(context);
      }

      String origen = arguments?['accountNumber'] as String? ?? 'Número de cuenta no disponible';
      String destino = accountNumber;
      double importe = amount;
      String typePart = 'Cargo';

      print('Llamando a doQr con:');
      print('Origen: $origen');
      print('Destino: $destino');
      print('Importe: $importe');

      bool success = await doQr(accessToken, origen, destino, importe);
      if (success) await addTransaction(accessToken, accountNumber, "add", importe);
      if (success) await addTransaction(accessToken, origen, "subtract", importe);
      print('doQr completado con éxito: $success');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateState(origen, destino, importe, typePart, success);
      });
    } else {
      print("El texto del QR no tiene el formato esperado.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateState('', '', -1, '', false);
      });
    }
  } catch (e) {
    print('Error al procesar el código QR: $e');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateState('', '', -1, '', false);
    });
  }
}
