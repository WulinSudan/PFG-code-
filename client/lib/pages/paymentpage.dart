import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../functions/encrypt.dart';
import '../functions/fetchPayKey.dart';
import '../functions/addKeyToDictionary.dart'; // Asegúrate de importar esta función
import '../functions/setNewKey.dart';


class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late String accountNumber = '';
  double amountToPay = -1;
  String qrData = '';
  TextEditingController amountController = TextEditingController();
  bool isDialogOpen = false;
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

  Future<void> updateQrData() async {
    setState(() {
      amountToPay = double.tryParse(amountController.text) ?? -1;
    });

    try {
      if (accessToken == null) {
        throw Exception("Access token is null");
      }

      String? payKey = await setNewKey(accessToken!, accountNumber);
      qrData = 'payment $accountNumber $amountToPay';
      String encryptedData = encryptAES(qrData, payKey!);

      // Guardar la clave en el diccionario
      await addKeyToDictionary(accessToken!, encryptedData, accountNumber, "payment");

      setState(() {
        qrData = encryptedData;
      });
      _showQrDialog();
    } catch (e) {
      // Manejo de errores
      print('Error obteniendo la Pay Key o añadiendo al diccionario: $e');
    }
  }

  Future<void> updateQrDataWithFreeAmount() async {
    setState(() {
      amountToPay = -1;
    });

    try {
      if (accessToken == null) {
        throw Exception("Access token is null");
      }

      String payKey = await fetchPayKey(accessToken!, accountNumber);
      qrData = 'payment $accountNumber $amountToPay';
      String encryptedData = encryptAES(qrData, payKey);

      // Guardar la clave en el diccionario
      await addKeyToDictionary(accessToken!, encryptedData, accountNumber, "payment");

      setState(() {
        qrData = encryptedData;
      });
      _showQrDialog();
    } catch (e) {
      // Manejo de errores
      print('Error obteniendo la Pay Key o añadiendo al diccionario: $e');
    }
  }

  void _showQrDialog() {
    const duration = Duration(seconds: 10);
    if (isDialogOpen) return; // Evita abrir múltiples diálogos

    isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Timer(duration, () {
          if (isDialogOpen) {
            Navigator.of(context).pop();
            setState(() {
              isDialogOpen = false;
            });
          }
        });

        return AlertDialog(
          title: Text('Codi QR per pagar'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: 'Import a pagar: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: amountToPay == -1 ? 'Libre' : '€$amountToPay',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text('Aquest codi QR es caducarà en:'),
                CountdownWidget(duration: duration),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isDialogOpen = false;
                });
              },
              child: Text('Tanca'),
            ),
          ],
        );
      },
    );
  }

  String maskAccountNumber(String accountNumber) {
    if (accountNumber.length != 10) {
      return 'Número de cuenta inválido';
    }

    String visibleDigits = accountNumber.substring(accountNumber.length - 6);
    String maskedDigits = accountNumber.substring(0, 4).replaceAll(RegExp(r'\d'), 'x');
    return '$maskedDigits$visibleDigits';
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
                      onPressed: updateQrData,
                      child: Text('Validar import'),
                    ),
                    ElevatedButton(
                      onPressed: updateQrDataWithFreeAmount,
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

class CountdownWidget extends StatefulWidget {
  final Duration duration;

  const CountdownWidget({Key? key, required this.duration}) : super(key: key);

  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  int _remainingSeconds = 10;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration.inSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_remainingSeconds seconds',
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
