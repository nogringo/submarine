import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

Uint8List generateRandomIV(int length) {
  final rnd = SecureRandom('AES/CTR/AUTO-SEED-PRNG');
  rnd.seed(KeyParameter(Uint8List(16))); // Seed the PRNG with 16 bytes
  return rnd.nextBytes(length);
}

String encryptText(String plaintext, Uint8List key) {
  // Convert plaintext to bytes
  final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));

  // Generate random IV (nonce)
  final iv = generateRandomIV(12); // GCM usually uses a 12-byte IV

  // Setup AES GCM Cipher
  final cipher = GCMBlockCipher(AESEngine());
  final params = AEADParameters(
    KeyParameter(key),
    128,
    iv,
    Uint8List(0),
  ); // 128-bit authentication tag

  cipher.init(true, params); // true = encryption mode

  // Perform encryption
  final encrypted = cipher.process(plaintextBytes);

  // Combine IV and encrypted data and return as base64 encoded string
  return base64Encode(iv + encrypted);
}

String decryptText(String encryptedBase64, Uint8List key) {
  // Decode the base64-encoded input
  final encryptedBytes = base64Decode(encryptedBase64);

  // Extract the IV from the first 12 bytes (GCM uses a 12-byte IV)
  final iv = encryptedBytes.sublist(0, 12);

  // Extract the actual encrypted data (ciphertext + tag) from the remaining bytes
  final ciphertextWithTag = encryptedBytes.sublist(12);

  // Setup AES GCM Cipher for decryption
  final cipher = GCMBlockCipher(AESEngine());
  final params = AEADParameters(
    KeyParameter(key),
    128,
    iv,
    Uint8List(0),
  ); // 128-bit authentication tag

  cipher.init(false, params); // false = decryption mode

  // Perform decryption
  final decryptedBytes = cipher.process(ciphertextWithTag);

  // Convert decrypted bytes back to a string
  return utf8.decode(decryptedBytes);
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
