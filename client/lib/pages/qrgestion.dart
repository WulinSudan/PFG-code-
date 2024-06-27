import 'package:flutter/material.dart';

class QrGestion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Recuperar el texto leído de los argumentos de la ruta
    String? qrText = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Capturado'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            qrText ?? 'Texto no disponible',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
