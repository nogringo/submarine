import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class EndToEndEncryption {
  static Future<SecretKey> derivatePassword(String password) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );

    // Calculate a hash that can be stored in the database
    final newSecretKey = await pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: const [
        252,
        206,
        248,
        13,
        117,
        70,
        39,
        40,
        87,
        240,
        226,
        174,
        67,
        195,
        25,
        8,
      ],
    );

    return newSecretKey;
  }

  static Future<String> encryptText(String text, SecretKey secretKey) async {
    final algorithm = AesGcm.with256bits();

    final data = utf8.encode(text);
    final nonce = algorithm.newNonce();

    final secretBox = await algorithm.encrypt(
      data,
      secretKey: secretKey,
      nonce: nonce,
    );

    // Encode the components using Base64
    final encodedCipherText = base64.encode(secretBox.cipherText);
    final encodedNonce = base64.encode(secretBox.nonce);
    final encodedMac = base64.encode(secretBox.mac.bytes);

    return '$encodedCipherText:$encodedNonce:$encodedMac';
  }

  static Future<String> decryptText(
    String encryptedData,
    SecretKey secretKey,
  ) async {
    final algorithm = AesGcm.with256bits();

    // Split the data by ':'
    final parts = encryptedData.split(':');
    if (parts.length != 3) {
      throw const FormatException('Invalid encrypted data format');
    }

    // Decode the components from Base64
    final cipherText = base64.decode(parts[0]);
    final nonce = base64.decode(parts[1]);
    final mac = base64.decode(parts[2]);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(mac),
    );

    final decryptedData = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(decryptedData);
  }
}
