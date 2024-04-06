import 'package:flutter/material.dart';

class QrMainPage extends StatelessWidget {

  final String username;

  QrMainPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Mis Cuentas - ${username}'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Alinea la imagen en la parte superior
          children: [
            SizedBox(height: 30.0),
            Image(
              image: AssetImage('assets/qr.png'),
            ),
            SizedBox(height: 20), // Espacio entre la imagen y el botón de texto
            TextButton(
              onPressed: () {
                // Acción para abrir la cámara
                Navigator.pushNamed(context, '/qrscannerpage');
              },
              child: Text(
                'Cámara',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20), // Espacio entre la imagen y el botón de texto
            TextButton(
              onPressed: () {
                // Acción para generar qr pagament
                Navigator.pushNamed(context, '/qrpayment');

              },
              child: Text(
                'Generar QR pagament',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
