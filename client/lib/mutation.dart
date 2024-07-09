import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt_package;
import 'dart:convert';

class MutationPage extends StatefulWidget {
  @override
  _MutationPageState createState() => _MutationPageState();
}

class _MutationPageState extends State<MutationPage> {
  String decryptedText = '';
  String encryptedText = '';
  String base64Key = '';
  String base64IV = '';

  // Clave y IV predeterminados (asegúrate de usar valores adecuados para tu caso)
  final keyBytes = utf8.encode('12345678901234567890123456789012'); // 32 bytes
  final ivBytes = utf8.encode('1234567890123456'); // 16 bytes

  // Crear la clave y el IV usando los bytes predeterminados
  late final encrypt_package.Key key;
  late final encrypt_package.IV iv;

  @override
  void initState() {
    super.initState();

    // Inicializar la clave y el IV
    key = encrypt_package.Key(keyBytes);
    iv = encrypt_package.IV(ivBytes);

    // Convertir la clave y el IV a base64
    base64Key = base64.encode(key.bytes);
    base64IV = base64.encode(iv.bytes);

    // Imprimir las versiones en base64 de la clave y el IV
    print('Clave en Base64: $base64Key');
    print('IV en Base64: $base64IV');

    _encryptData();
  }

  void _encryptData() {
    final plainText = 'hola';
    final encrypter = encrypt_package.Encrypter(encrypt_package.AES(key));
    final encrypted = _encrypt(plainText, encrypter);
    final decrypted = _decrypt(encrypted, encrypter);

    setState(() {
      decryptedText = decrypted;
      encryptedText = encrypted;
    });
  }

  String _encrypt(String plainText, encrypt_package.Encrypter encrypter) {
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String _decrypt(String encryptedBase64, encrypt_package.Encrypter encrypter) {
    final encrypted = encrypt_package.Encrypted.fromBase64(encryptedBase64);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mutation Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Decrypted Text: $decryptedText'),
            SizedBox(height: 16.0),
            Text('Encrypted Text: $encryptedText'),
            SizedBox(height: 16.0),
            Text('Key (Base64): $base64Key'),
            Text('IV (Base64): $base64IV'),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: MutationPage()));
