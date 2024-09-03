import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/encrypt.dart';
import '../functions/addDictionary.dart';
import '../functions/setNewKey.dart';
import '../internal_functions/maskAccountNumber.dart';
import '../dialogs/qr_dialog.dart';
import '../functions/checkEnableAmout.dart';
import '../dialogs_simples/errorDialog.dart';

// Formatter to limit the number of decimals to 2 and ensure the number is > 0
class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String newText = newValue.text;

    // Si el texto está vacío, permitir la actualización
    if (newText.isEmpty) {
      return newValue;
    }

    // Si el texto no es un número válido (por ejemplo, "-", ".", "-."), regresar el valor anterior
    if (double.tryParse(newText) == null) {
      return oldValue;
    }

    // No permitir números negativos o cero
    if (double.parse(newText) <= 0) {
      return oldValue;
    }

    // Si el texto contiene más de una coma o punto, regresar el valor anterior
    if (newText.indexOf('.') != newText.lastIndexOf('.')) {
      return oldValue;
    }

    // Verificar la cantidad de decimales permitidos
    final int indexOfDot = newText.indexOf('.');
    if (indexOfDot != -1) {
      final int decimals = newText.length - indexOfDot - 1;
      if (decimals > decimalRange) {
        return oldValue;
      }
    }

    return newValue;
  }
}

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String accountNumber = '';
  double amountToPay = -1;
  String qrData = '';
  TextEditingController amountController = TextEditingController();
  String? accessToken;
  String? payKey;
  bool isAmountValid = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args.containsKey('accountNumber') && args.containsKey('accessToken')) {
        setState(() {
          accountNumber = args['accountNumber'];
          accessToken = args['accessToken'];
        });
      }
    });

    // Add listener to the amountController to validate input
    amountController.addListener(_validateAmount);
  }

  @override
  void dispose() {
    // Remove listener when the widget is disposed
    amountController.removeListener(_validateAmount);
    amountController.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  void _validateAmount() {
    final amountText = amountController.text;
    final amount = double.tryParse(amountText);
    setState(() {
      isAmountValid = amount != null && amount > 0;
    });
  }

  Future<void> generateQrData({required bool isFreeAmount}) async {
    double amount = double.tryParse(amountController.text) ?? -1;

    setState(() {
      amountToPay = isFreeAmount ? -1 : amount;
    });

    try {
      if (accessToken == null) {
        throw Exception("Access token is null");
      }

      if (amountToPay != -1) {
        bool amountAcceptable = await checkEnableAmount(accessToken!, accountNumber, amountToPay);
        if (!amountAcceptable) {
          errorDialog(context, "Amount not acceptable");
          throw Exception("Amount not acceptable");
        }
      }

      // Create new key, use it, and store in database
      payKey = await setNewKey(accessToken!, accountNumber);

      qrData = 'payment $accountNumber $amountToPay';
      String encryptedData = encryptAES(qrData, payKey!);

      await addDictionary(accessToken!, encryptedData, accountNumber);

      setState(() {
        qrData = encryptedData;
      });

      QrDialog.showQrDialog(context, qrData, amountToPay);
    } catch (e) {
      print('Error generating payment key or adding to dictionary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 30.0),
                Text('Account Number: ${maskAccountNumber(accountNumber)}'),
                SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter the amount you want to pay',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    DecimalTextInputFormatter(decimalRange: 2),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: isAmountValid ? () => generateQrData(isFreeAmount: false) : null,
                      child: Text('Validate amount'),
                    ),
                    ElevatedButton(
                      onPressed: () => generateQrData(isFreeAmount: true),
                      child: Text('Free amount'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
