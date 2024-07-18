import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pointycastle/asymmetric/api.dart'; // Para RSAPublicKey

void main() => runApp(MaterialApp(home: MutationPage()));

class MutationPage extends StatefulWidget {
  @override
  _MutationPageState createState() => _MutationPageState();
}

class _MutationPageState extends State<MutationPage> {
  RSAPublicKey? publicKey;
  RSAPrivateKey? privKey;
  final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
  String? encryptedBase64;
  String? decrypted;

  @override
  void initState() {
    super.initState();
    _initializeKeys();
  }

  Future<String> loadPemFile(String path) async {
    try {
      // Cargar el archivo PEM como un string
      String pemString = await rootBundle.loadString(path);
      return pemString;
    } catch (e) {
      print('Error al cargar el archivo PEM: $e');
      return '';
    }
  }


  Future<void> _initializeKeys() async {
    try {

      final publicPem = await rootBundle.loadString('assets/public_key.pem');
      // Cargar claves desde archivos PEM
      String publicKeyString = await loadPemFile('assets/public_key.pem');
      print("---------------------44-----------------");
      print(publicKeyString);
      print("---------------------46-----------------");


      publicKey = RSAKeyParser().parse(publicPem) as RSAPublicKey;
      //publicKey = await parseKeyFromFile<RSAPublicKey>('assets/public_key.pem');

      privKey = await parseKeyFromFile<RSAPrivateKey>('assets/private_key.pem');

      _encryptAndDecrypt();
    } catch (e) {
      print('Error al cargar las claves: $e');
    }
  }

  void _encryptAndDecrypt() {
    if (publicKey != null && privKey != null) {
      // PKCS1 (Default)
      final encrypter = Encrypter(RSA(publicKey: publicKey!, privateKey: privKey!));
      final encrypted = encrypter.encrypt(plainText);
      decrypted = encrypter.decrypt(encrypted);
      encryptedBase64 = encrypted.base64;

      // Actualizar el estado para reflejar los nuevos valores
      setState(() {});
    } else {
      print('Las claves no se han cargado correctamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mutation Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Mensaje en claro: $plainText'),
            SizedBox(height: 16),
            Text('Mensaje encriptado (Base64): ${encryptedBase64 ?? "Cargando..."}'),
            SizedBox(height: 16),
            Text('Mensaje desencriptado: ${decrypted ?? "Cargando..."}'),
          ],
        ),
      ),
    );
  }
}
