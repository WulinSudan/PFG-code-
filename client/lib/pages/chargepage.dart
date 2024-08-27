import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../utils/encrypt.dart';
import '../functions/addDictionary.dart';
import '../internal_functions/maskAccountNumber.dart';

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

        // Inicializar qrData con un importe de -1 al cargar la página
        await _initializeQrData();
      }
    });
  }

  Future<void> _initializeQrData() async {
    if (accessToken == null) {
      print("Access token is null");
      return;
    }

    try {
      //String chargeKey = await fetchChargeKey(accessToken!, accountNumber);
      qrData = 'charge $accountNumber $amountToCharge';
      //String encryptedData = encryptAES(qrData, chargeKey);
      print("encryptedData..................................");
      print(qrData);
      // Guardar la clave en el diccionario
      print("en la classe chargepage");
      print(accessToken);
      print(accountNumber);


    } catch (e) {
      print('Error obteniendo la Pay Key o añadiendo al diccionario: $e');
      // Aquí podrías mostrar un mensaje de error al usuario si lo deseas
    }
  }

  Future<void> updateQrData() async {
    if (accessToken == null) {
      print("Access token is null");
      return;
    }

    setState(() {
      amountToCharge = double.tryParse(amountController.text) ?? -1;
    });

    try {

      //String chargeKey = await fetchChargeKey(accessToken!, accountNumber);

      qrData = 'charge $accountNumber $amountToCharge';
      //String encryptedData = encryptAES(qrData, chargeKey);
      print("encryptedData..................................");
      print(qrData);
      // Guardar la clave en el diccionario
      //await addKeyToDictionary(accessToken!, encryptedData, accountNumber, "charge");

    } catch (e) {
      print('Error obteniendo la Pay Key o añadiendo al diccionario: $e');
      // Aquí podrías mostrar un mensaje de error al usuario si lo deseas
    }
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
                  onChanged: (_) {
                    // Actualizar QR solo cuando se presione el botón
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter the amount you want to charge',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    updateQrData();
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