// paymentGestion.dart
import 'package:client/functions/addTransaction.dart';
import 'package:flutter/material.dart';
import '../functions/checkEnable.dart';
import '../functions/getOriginAccount.dart';
import '../functions/fetchPayKey.dart';
import '../functions/encrypt.dart';
import '../functions/doQr.dart';
import '../functions/setQrUsed.dart';
import '../dialogs/confirmationDialog.dart';
import '../dialogs/getImportDialog.dart';


Future<void> processQrPayment(
    BuildContext context,
    String qrText,
    Map<String, dynamic>? arguments,
    String accessToken,
    Function(String, String, double, String, bool) updateState,
    ) async {
  print("Código QR de pago");

  String? originAccount;
  String? key;
  bool success = false;

  try {
    // Obtener cuenta origen
    originAccount = await getOrigenAccount(accessToken, qrText);
    print('Cuenta origen: $originAccount');

    // Obtener la clave
    key = await fetchPayKey(accessToken, originAccount!);
    print('Clave obtenida: $key');

    // Obtener la cuenta escaneadora
    String cuentaEscaneadora = arguments?['accountNumber'] as String? ?? 'Número de cuenta no disponible';
    print('Cuenta escaneadora: $cuentaEscaneadora');

    // Desencriptar mensaje
    String mensajeClaro = decryptAES(qrText, key!);
    print('Mensaje claro: $mensajeClaro');

    // Procesar el mensaje desencriptado
    String remainingText = mensajeClaro.substring("payment".length).trim();
    List<String> parts = remainingText.split(' ');

    if (parts.length == 2) {
      String accountNumber = parts[0];
      double? amount = double.tryParse(parts[1]);

      if (amount == null || amount <= 0) {
        amount = await getImportDialog(context) ?? 0.0;
      } else {
        await showConfirmationDialog(context);
      }

      String origen = cuentaEscaneadora;
      String destino = accountNumber;
      double importe = amount;
      String typePart = 'Cargo';

      print('Llamando a doQr con:');
      print('Origen: $origen');
      print('Destino: $destino');
      print('Importe: $importe');

      // Verificar si el QR está habilitado antes de llamar a doQr
      bool enable = await checkEnable(accessToken, qrText);
      if (enable) {
        success = await doQr(accessToken, origen, destino, importe);
        print('doQr completado con éxito: $success');
        print("Estoy en chargeGestion...................");

        // Deshabilitar el QR solo si la transferencia fue exitosa
        if (success) {
          print("Estoy en la funcion paymentGestion");
          await addTransaction(accessToken, accountNumber, "add", importe);
          await addTransaction(accessToken, origen, "subtract", importe);
          await setQrUsed(accessToken, qrText);
        }
      } else {
        print("QR caducado o usado.....................................................");
      }

      updateState(origen, destino, importe, typePart, success);
    } else {
      print("El texto del QR no tiene el formato esperado.");
      updateState('', '', -1, '', false);
    }
  } catch (e) {
    print('Error al procesar el código QR: $e');
    updateState('', '', -1, '', false);
  }
}
