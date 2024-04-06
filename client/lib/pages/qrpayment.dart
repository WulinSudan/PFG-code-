import 'dart:async';
import 'package:flutter/material.dart';

class QrPayment extends StatefulWidget {
  const QrPayment({Key? key}) : super(key: key);

  @override
  State<QrPayment> createState() => _QrPaymentState();
}

class _QrPaymentState extends State<QrPayment> {
  TextEditingController _amountController = TextEditingController();
  double? _amount;
  bool _showQrCode = false;
  int _secondsRemaining = 10;
  late Timer _timer;

  @override
  void dispose() {
    _amountController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          _showQrCode = false; // Desactiva la visualización del código QR
          Navigator.pop(context); // Vuelve a la página anterior
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Introduce el importe',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _amount = double.tryParse(_amountController.text);
                  _showQrCode = true;
                  _startTimer();
                });
              },
              child: Text('Generar'),
            ),
            SizedBox(height: 20),
            if (_showQrCode)
              Column(
                children: [
                  Image.asset('assets/qr.png'),
                  SizedBox(height: 20),
                  Text(
                    'Tiempo restante: $_secondsRemaining segundos',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _timer.cancel();
                        _showQrCode = false;
                      });
                      Navigator.pop(context); // Vuelve a la página anterior
                    },
                    child: Text('Cancelar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
