import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Importa el paquete qr_flutter

class MutationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Example'),
      ),
      body: Center(
        child: QrImageView(
          data: 'hola',
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
