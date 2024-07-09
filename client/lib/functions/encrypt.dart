import 'package:encrypt/encrypt.dart' as encrypt;

final encrypt.Key key = encrypt.Key.fromUtf8('my 32 length key................'); // Define tu propia clave
//final encrypt.IV iv = encrypt.IV.fromUtf8('my 16 length iv..'); // Define tu propio IV
final encrypt.IV iv = encrypt.IV.fromLength(16); // IV con longitud de 16 bytes

Future<String> encryptData(String plainText) async {
  try {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    print("----------------------10-------------------------");
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    print("----------------------12-------------------------");
    print(encrypted.base64);
    return encrypted.base64;
  } catch (e) {
    print('Error en encryptData: $e');
    return ''; // Otra acción según sea necesario
  }
}

Future<String> decryptData(String encryptedBase64) async {
  try {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  } catch (e) {
    print('Error en decryptData: $e');
    return ''; // Otra acción según sea necesario
  }
}
