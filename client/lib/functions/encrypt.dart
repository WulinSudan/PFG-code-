import 'package:encrypt/encrypt.dart' as encrypt;

class MyEncryptionDecryption {


 //static final key = encrypt.Key.fromLength(32);
 //static final iv = encrypt.IV.fromLength(16);


  static final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  //static final iv = encrypt.IV.fromSecureRandom(16);

  static final iv = encrypt.IV.fromBase64('FxIOBAcEEhISHgICCRYhEA==');

  static final encrypt.Encrypter encrypter = encrypt.Encrypter(encrypt.AES(key));

  static String encryptAES(String text) {
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64;
  }

  static String decryptAES(String encryptedBase64) {
    final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }
}
