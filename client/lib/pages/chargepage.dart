import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Asegúrate de tener esta dependencia

class ChargePage extends StatefulWidget {
  @override
  _ChargePageState createState() => _ChargePageState();
}

class _ChargePageState extends State<ChargePage> {
  late String accountNumber = '';
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
          qrData = 'destination:$accountNumber,importe:0';
        });
      }
    });
  }

  void _updateQrCode() {
    setState(() {
      qrData = 'accountNumber:$accountNumber,importe:${amountController.text}';
    });
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
                Text('Account Number: ${accountNumber}'),
                SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter the amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateQrCode,
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
