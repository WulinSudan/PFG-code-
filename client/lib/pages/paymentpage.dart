import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../functions/encrypt.dart';
import '../functions/fetchPayKey.dart';
import '../functions/addKeyToDictionary.dart';
import '../functions/setNewKey.dart';
import '../internal_functions/maskAccountNumber.dart';
import '../dialogs/qr_dialog.dart'; // Importa el nuevo archivo

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late String accountNumber = '';
  double amountToPay = -1;
  String qrData = '';
  TextEditingController amountController = TextEditingController();
  String? accessToken;

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
  }

  Future<void> generateQrData({required bool isFreeAmount}) async {
    setState(() {
      amountToPay = isFreeAmount ? -1 : (double.tryParse(amountController.text) ?? -1);
    });

    try {
      if (accessToken == null) {
        throw Exception("Access token is null");
      }

      String payKey = isFreeAmount
          ? await fetchPayKey(accessToken!, accountNumber)
          : (await setNewKey(accessToken!, accountNumber))!;

      qrData = 'payment $accountNumber $amountToPay';
      String encryptedData = encryptAES(qrData, payKey);

      // Guardar la clave en el diccionario
      await addKeyToDictionary(accessToken!, encryptedData, accountNumber, "payment");

      setState(() {
        qrData = encryptedData;
      });
      QrDialog.showQrDialog(context, qrData, amountToPay);
    } catch (e) {
      print('Error generando la clave de pago o añadiendo al diccionario: $e');
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
                    labelText: 'Entrar el import que es vol pagar (buit=màxim)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => generateQrData(isFreeAmount: false),
                      child: Text('Validar import'),
                    ),
                    ElevatedButton(
                      onPressed: () => generateQrData(isFreeAmount: true),
                      child: Text('Importe libre'),
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
