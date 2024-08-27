import 'package:client/functions/addTransaction.dart';
import 'package:flutter/material.dart';
import '../functions/checkEnable.dart';
import '../functions/getOrigenAccount.dart';
import '../functions/fetchPayKey.dart';
import '../utils/encrypt.dart';
import '../functions/doQr.dart';
import '../functions/setQrUsed.dart';
import '../dialogs_simples/okDialog.dart';
import '../dialogs/getImportDialog.dart';
import '../functions/getAccountBalance.dart';

Future<void> processQrPayment(
    BuildContext context,
    String qrText,
    Map<String, dynamic>? arguments,
    String accessToken,
    Function(String, String, double, String, bool) updateState,
    ) async {
  print("Processing QR payment");

  String? originAccount;
  String? key;
  bool success = false;

  try {
    // Get the origin account
    originAccount = await getOrigenAccount(accessToken, qrText);
    // Fetch the key for decryption
    key = await fetchPayKey(accessToken, originAccount!);
    // Get the scanning account
    String scanningAccount = arguments?['accountNumber'] as String? ?? 'Account number not available';


    // Decrypt the QR code message
    String decryptedMessage = decryptAES(qrText, key!);


    // Process the decrypted message
    String remainingText = decryptedMessage.substring("payment".length).trim();
    List<String> parts = remainingText.split(' ');

    if (parts.length == 2) {
      String accountNumber = parts[0];
      double? amount = double.tryParse(parts[1]);

      if (amount == null || amount <= 0) {
        amount = await getImportDialog(context) ?? 0.0;
        await okDialog(context, "Identifying");
      } else {
        await okDialog(context, "Identifying");
      }

      String origin = scanningAccount;
      String destination = accountNumber;
      double importAmount = amount;
      String transactionType = 'Charge';


      double originBalance = await getAccountBalance(accessToken, origin);
      double destinationBalance = await getAccountBalance(accessToken, destination);

      // Check if the QR code is enabled before calling doQr
      bool isEnabled = await checkEnable(accessToken, qrText);
      if (isEnabled) {
        success = await doQr(accessToken, destination, origin, importAmount);

        // Disable the QR code only if the transfer was successful
        if (success) {
          print("In paymentGestion function");
          await addTransaction(accessToken, accountNumber, "subtract", importAmount, originBalance);
          await addTransaction(accessToken, origin, "add", importAmount, destinationBalance);
          await setQrUsed(accessToken, qrText);
        }
      } else {
        print("QR code expired or already used...");
      }

      updateState(origin, destination, importAmount, transactionType, success);
    } else {
      print("The QR text does not have the expected format.");
      updateState('', '', -1, '', false);
    }
  } catch (e) {
    print('Error processing QR code: $e');
    updateState('', '', -1, '', false);
  }
}
