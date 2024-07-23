import 'package:encrypt/encrypt.dart' as encrypt;

String encryptAES(String text, String ivString) {
  final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final iv = encrypt.IV.fromUtf8(ivString);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final encrypted = encrypter.encrypt(text, iv: iv);
  return encrypted.base64;
}

String decryptAES(String encryptedBase64, String ivString) {
  final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final iv = encrypt.IV.fromUtf8(ivString);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  return decrypted;
}
