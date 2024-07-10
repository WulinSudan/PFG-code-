import 'package:flutter/material.dart';

// Importa la clase MyEncryptionDecryption
import 'my_encryption.dart';

void main() => runApp(MaterialApp(home: MutationPage()));

class MutationPage extends StatefulWidget {
  @override
  _MutationPageState createState() => _MutationPageState();
}

class _MutationPageState extends State<MutationPage> {
  late TextEditingController _textController;
  String _encryptedText = '';
  String _decryptedText = '';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void encryptText() {
    // Obtén el texto del TextField
    String plainText = _textController.text;

    // Llama al método estático encryptAES de MyEncryptionDecryption
    _encryptedText = MyEncryptionDecryption.encryptAES(plainText);
    _decryptedText = ''; // Limpiar el texto desencriptado
    setState(() {});
  }

  void decryptText() {
    // Llama al método estático decryptAES de MyEncryptionDecryption
    _decryptedText = MyEncryptionDecryption.decryptAES(_encryptedText);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mutation Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Enter text to encrypt/decrypt',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: encryptText,
                child: Text('Encrypt'),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: decryptText,
                child: Text('Decrypt'),
              ),
              SizedBox(height: 20.0),
              Text('Encrypted Text:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_encryptedText),
              SizedBox(height: 20.0),
              Text('Decrypted Text:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_decryptedText),
            ],
          ),
        ),
      ),
    );
  }
}
