import 'package:flutter/material.dart';

class ChargePage extends StatefulWidget {
  final String accountNumber= "123";

  //ChargePage({required this.accountNumber});

  @override
  _ChargePageState createState() => _ChargePageState();
}

class _ChargePageState extends State<ChargePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cargar Cuenta'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Número de cuenta seleccionada:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              widget.accountNumber,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
