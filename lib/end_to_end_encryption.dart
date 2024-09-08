import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

Uint8List generateRandomIV(int length) {
  final random = Random.secure();
  final iv = Uint8List(length);

  for (int i = 0; i < length; i++) {
    iv[i] = random.nextInt(256);
  }

  return iv;
}

Uint8List pad(Uint8List data, int blockSize) {
  int padding = blockSize - (data.length % blockSize);
  return Uint8List.fromList(data + List<int>.filled(padding, padding));
}

Uint8List unpad(Uint8List paddedData) {
  int padding = paddedData.last;
  return paddedData.sublist(0, paddedData.length - padding);
}

String encryptText(String plaintext, Uint8List key) {
  final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
  final paddedPlaintext = pad(plaintextBytes, 16);

  final iv = generateRandomIV(16);

  final cipher = CBCBlockCipher(AESEngine());
  final params = ParametersWithIV(KeyParameter(key), iv);

  cipher.init(true, params);

  final encrypted = Uint8List(paddedPlaintext.length);
  for (var i = 0; i < paddedPlaintext.length; i += cipher.blockSize) {
    cipher.processBlock(paddedPlaintext, i, encrypted, i);
  }

  return base64Encode(iv + encrypted);
}

String decryptText(String encryptedText, Uint8List key) {
  final encryptedBytes = base64Decode(encryptedText);

  final iv = encryptedBytes.sublist(0, 16);
  final encryptedData = encryptedBytes.sublist(16);

  final cipher = CBCBlockCipher(AESEngine());
  final params = ParametersWithIV(KeyParameter(key), iv);

  cipher.init(false, params);

  final decrypted = Uint8List(encryptedData.length);
  for (var i = 0; i < encryptedData.length; i += cipher.blockSize) {
    cipher.processBlock(encryptedData, i, decrypted, i);
  }

  final unpaddedDecrypted = unpad(decrypted);

  return utf8.decode(unpaddedDecrypted);
}

Uint8List generateKey(String password) {
  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
    ..init(Pbkdf2Parameters(
      Uint8List.fromList([
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
      ]),
      1000, //! good security is about 650000
      32,
    ));

  return derivator.process(Uint8List.fromList(utf8.encode(password)));
}
