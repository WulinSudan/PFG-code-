import 'package:flutter/material.dart';

class ChargePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final accountNumber = args['accountNumber'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Charge Page'),
      ),
      body: Center(
        child: Text('Account Number: $accountNumber'),
      ),
    );
  }
}
