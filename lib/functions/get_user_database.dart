import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_flutter/ndk_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'dart:convert';

const _signerFactory = NdkEventSignerFactory();

class Nip44AsyncCodec extends AsyncContentCodecBase {
  final String privateKey;
  final EventSigner signer;
  final String publicKey;

  Nip44AsyncCodec({required this.privateKey})
    : signer = _signerFactory.create(privateKey: privateKey),
      publicKey = _signerFactory.derivePublicKey(privateKey);

  @override
  Future<Object?> decodeAsync(String encoded) async {
    final plaintext = await signer.decryptNip44(
      ciphertext: encoded,
      senderPubKey: publicKey,
    );
    if (plaintext == null)
      throw StateError("Failed to decrypt database record");
    return jsonDecode(plaintext);
  }

  @override
  Future<String> encodeAsync(Object? input) async {
    final ciphertext = await signer.encryptNip44(
      plaintext: jsonEncode(input),
      recipientPubKey: publicKey,
    );
    if (ciphertext == null) {
      throw StateError("Failed to encrypt database record");
    }
    return ciphertext;
  }
}

Future<Database> getUserDatabase(String pubkey) async {
  const secureStorage = FlutterSecureStorage();

  // Get or create encryption key (nsec) for this user's database
  final encryptionKeyName = 'db_encryption_key_$pubkey';
  String? encryptionKey = await secureStorage.read(key: encryptionKeyName);
  if (encryptionKey == null) {
    // Generate a new nsec for database encryption
    final (privateKey, _) = _signerFactory.generateKeyPair();
    encryptionKey = privateKey;
    await secureStorage.write(key: encryptionKeyName, value: encryptionKey);
  }

  // Create NIP-44 codec with the encryption key
  final codec = Nip44AsyncCodec(privateKey: encryptionKey);
  final sembastCodec = SembastCodec(
    signature: "nip44_codec_$pubkey",
    codec: codec,
  );

  final folderName = kDebugMode ? "Submarine-dev" : "Submarine";

  if (kIsWeb) {
    final factory = databaseFactoryWeb;
    return await factory.openDatabase(
      '$folderName/$pubkey',
      codec: sembastCodec,
    );
  } else {
    final factory = databaseFactoryIo;
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbFolder = path.join(appDocDir.path, folderName);
    final dbPath = path.join(dbFolder, "$pubkey.db");

    // Ensure the folder exists
    final dir = Directory(dbFolder);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return await factory.openDatabase(dbPath, codec: sembastCodec);
  }
}
