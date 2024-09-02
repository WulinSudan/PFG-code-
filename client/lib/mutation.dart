import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: MutationPage()));

class MutationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mutation Page')),
      body: Center(
        child: Text('Hola', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
