import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../utils/encrypt.dart';
import '../functions/addDictionary.dart';
import '../internal_functions/maskAccountNumber.dart';

import 'package:flutter/services.dart'; // Afegeix aquesta línia

class ChargePage extends StatefulWidget {
  @override
  _ChargePageState createState() => _ChargePageState();
}

class _ChargePageState extends State<ChargePage> {
  late String accountNumber = '';
  double amountToCharge = -1; // Importe a pagar
  String qrData = ''; // Inicialmente vacío
  String? accessToken;
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args.containsKey('accountNumber') && args.containsKey('accessToken')) {
        setState(() {
          accountNumber = args['accountNumber']!;
          accessToken = args['accessToken'];
        });
      }
    });
  }

  Future<void> updateQrData() async {
    if (accessToken == null) {
      print("Access token is null");
      return;
    }
    setState(() {
      amountToCharge = double.tryParse(amountController.text) ?? -1;
    });
  }

  bool isAmountValid(String value) {
    final regex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (regex.hasMatch(value)) {
      final amount = double.tryParse(value);
      return amount != null && amount > 0;
    }
    return false;
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
                  data: qrData.isEmpty ? 'c $accountNumber $amountToCharge' : qrData, // Asegura que qrData tenga algún valor
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                SizedBox(height: 20),
                Text('Account Number: ${maskAccountNumber(accountNumber)}'),
                Text('Amount: ${amountToCharge == -1 ? 'Free' : amountToCharge}'),
                SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter the amount you want to charge',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (isAmountValid(amountController.text)) {
                      updateQrData();
                    }
                  },
                  child: Text('Update QR Code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
