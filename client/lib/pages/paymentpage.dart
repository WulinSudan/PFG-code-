import 'dart:async'; // Importar dart:async para usar Timer

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late String accountNumber = '';
  double amountToPay = -1; // Importe a pagar
  String qrData = ''; // Datos para el código QR
  TextEditingController amountController = TextEditingController();
  bool isDialogOpen = false; // Para controlar si el AlertDialog está abierto


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
      amountToPay = double.tryParse(amountController.text) ?? -1;
      qrData = 'p $accountNumber $amountToPay';
    });

    _showQrDialog(); // Mostrar el AlertDialog con el código QR generado
  }

  void _showQrDialog() {
    const duration = const Duration(seconds: 10);
    isDialogOpen = true; // Indicar que el AlertDialog está abierto

    showDialog(
      context: context,
      barrierDismissible: false, // Evitar que se cierre al tocar fuera
      builder: (context) {
        // Iniciar un Timer para cerrar automáticamente después de 10 segundos
        Timer(duration, () {
          if (isDialogOpen) {
            Navigator.of(context).pop(); // Cerrar el AlertDialog
            isDialogOpen = false; // Indicar que el AlertDialog está cerrado
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
                    data: qrData, // Usar qrData que has actualizado
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
                        text: '€$amountToPay',
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
                CountdownWidget(duration: duration), // Widget para mostrar el contador de tiempo
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                isDialogOpen = false; // Indicar que el AlertDialog está cerrado
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

    String visibleDigits = accountNumber.substring(accountNumber.length - 6); // Muestra los últimos 6 dígitos
    String maskedDigits = accountNumber.substring(0, 4).replaceAll(RegExp(r'\d'), 'x'); // Oculta los primeros 4 dígitos
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
                ElevatedButton(
                  onPressed: updateQrData,
                  child: Text('Validar import'),
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
