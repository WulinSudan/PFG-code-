import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Asegúrate de tener esta dependencia

class ChargePage extends StatefulWidget {
  @override
  _ChargePageState createState() => _ChargePageState();
}

class _ChargePageState extends State<ChargePage> {
  late String accountNumber = '';
  double amountToCharge = -1; // Importe a pagar
  String qrData = '';
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args.containsKey('accountNumber')) {
        setState(() {
          accountNumber = args['accountNumber']!;
          updateQrData();
        });
      }
    });
  }

  void updateQrData() {
    setState(() {
      amountToCharge = double.tryParse(amountController.text) ?? -1;
      qrData = 'c $accountNumber $amountToCharge';
    });
  }

  String maskAccountNumber(String accountNumber) {
    if (accountNumber.length != 10) {
      return 'Número de cuenta inválido';
    }

    String visibleDigits = accountNumber.substring(accountNumber.length - 6); // Muestra los últimos 6 dígitos
    String maskedDigits = accountNumber.substring(0, 4).replaceAll(RegExp(r'\d'), 'x'); // Oculta los primeros 4 dígitos
    return '$maskedDigits$visibleDigits';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charge Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 30.0),
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                SizedBox(height: 20),
                Text('Account Number: ${maskAccountNumber(accountNumber)}'),
                Text('Import: ${amountController.text.isEmpty ? 'undefined' : amountController.text}'),
                SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  onChanged: (_) => updateQrData(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter the amount',
                  ),
                  keyboardType: TextInputType.number,
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
