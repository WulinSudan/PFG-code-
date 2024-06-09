import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Asegúrate de tener esta dependencia

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
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
          qrData = 'accountNumber:$accountNumber,importe:0';
        });
      }
    });
  }

  void _updateQrCode() {
    setState(() {
      qrData = 'accountNumber:$accountNumber,importe:${amountController.text}';
    });
    _showInfoDialog();
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles del pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Número de cuenta: $accountNumber'),
              Text('Importe: ${amountController.text}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
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
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                SizedBox(height: 20),
                Text('Account Number: $accountNumber'),
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
