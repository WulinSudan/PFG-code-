import 'package:flutter/material.dart';
import '../functions/doQr.dart'; // Ensure the path is correct
import '../dialogs/getImportDialog.dart'; // Ensure the path is correct
import '../dialogs/logoutDialog.dart';
import '../dialogs_simples/okDialog.dart';
import '../functions/addTransaction.dart';
import '../functions/getAccountBalance.dart';

Future<void> processQrCharge(
    BuildContext context,
    String qrText,
    Map<String, dynamic>? arguments,
    String accessToken,
    Function(String, String, double, String, bool) updateState,
    ) async {
  try {
    print('Starting processQrCharge with qrText: $qrText');
    String remainingText = qrText.substring("charge".length).trim();
    List<String> parts = remainingText.split(' ');
    if (parts.length == 2) {
      String accountNumber = parts[0];
      double? amount = double.tryParse(parts[1]);

      if (amount == null || amount <= 0) {
        amount = await getImportDialog(context) ?? 0.0;
        await okDialog(context,"Identifying");
        print("On the chargeManagement.dart page, the collected amount: $amount");
      } else {
        await okDialog(context,"Identifying");
      }

      String origin = arguments?['accountNumber'] as String? ?? 'Account number not available';
      String destination = accountNumber;
      double amountValue = amount;
      String typePart = 'Charge';

      double balanceOrigin = await getAccountBalance(accessToken, origin);
      double balanceDestination = await getAccountBalance(accessToken, destination);

      print('Calling doQr with:');
      print('Origin: $origin');
      print('Destination: $destination');
      print('Amount: $amountValue');

      bool success = await doQr(accessToken, origin, destination, amountValue);
      if (success) await addTransaction(accessToken, accountNumber, "add", amountValue, balanceOrigin);
      if (success) await addTransaction(accessToken, origin, "subtract", amountValue, balanceDestination);
      print('doQr completed successfully: $success');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateState(origin, destination, amountValue, typePart, success);
      });
    } else {
      print("The QR text does not have the expected format.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateState('', '', -1, '', false);
      });
    }
  } catch (e) {
    print('Error processing QR code: $e');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateState('', '', -1, '', false);
    });
  }
}
