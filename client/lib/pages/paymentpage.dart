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
          qrData = 'origin:$accountNumber,importe:0';
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
                  child: Text('Validar import'),
                ),

                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Codi qr para cobrar'),
                          content: Container(
                            width: 200,
                            height: 200,
                            child: QrImageView(
                              data: 'Número de cuenta:',
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cerrar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Obtenir Codi QR'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}