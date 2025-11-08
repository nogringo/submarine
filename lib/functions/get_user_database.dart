import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:ndk/shared/nips/nip44/nip44.dart';
import 'package:nip01/nip01.dart';
import 'dart:convert';

class Nip44AsyncCodec extends AsyncContentCodecBase {
  final String privateKey;
  final String publicKey;

  Nip44AsyncCodec({required this.privateKey})
    : publicKey = KeyPair.fromPrivateKey(privateKey: privateKey).publicKey;

  @override
  Future<Object?> decodeAsync(String encoded) async {
    return jsonDecode(
      await Nip44.decryptMessage(encoded, privateKey, publicKey),
    );
  }

  @override
  Future<String> encodeAsync(Object? input) async {
    return await Nip44.encryptMessage(jsonEncode(input), privateKey, publicKey);
  }
}

Future<Database> getUserDatabase(String pubkey) async {
  const secureStorage = FlutterSecureStorage();

  // Get or create encryption key (nsec) for this user's database
  final encryptionKeyName = 'db_encryption_key_$pubkey';
  String? encryptionKey = await secureStorage.read(key: encryptionKeyName);
  if (encryptionKey == null) {
    // Generate a new nsec for database encryption
    encryptionKey = KeyPair.generate().privateKey;
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
    return await factory.openDatabase('$folderName/$pubkey', codec: sembastCodec);
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
