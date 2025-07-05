import 'dart:async';
import 'dart:convert';
import 'package:ndk/shared/nips/nip44/nip44.dart';
import 'package:nip01/nip01.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  final _secureStorage = const FlutterSecureStorage();
  static const String _dbName = 'submarine.db';
  static const String _encryptionKeyKey = 'db_encryption_key';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final encryptionKey = await _getOrCreateEncryptionKey();
    final codec = Nip44AsyncCodec(privateKey: encryptionKey);
    final sembastCodec = SembastCodec(signature: "nip44_codec", codec: codec);

    if (kIsWeb) {
      final factory = databaseFactoryWeb;
      return await factory.openDatabase(_dbName, codec: sembastCodec);
    } else {
      final factory = databaseFactoryIo;
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = path.join(appDocDir.path, _dbName);
      return await factory.openDatabase(dbPath, codec: sembastCodec);
    }
  }

  Future<String> _getOrCreateEncryptionKey() async {
    String? key = await _secureStorage.read(key: _encryptionKeyKey);
    if (key == null) {
      key = _generateEncryptionKey();
      await _secureStorage.write(key: _encryptionKeyKey, value: key);
    }
    return key;
  }

  String _generateEncryptionKey() {
    return KeyPair.generate().privateKey;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    await close();
    await _secureStorage.delete(key: _encryptionKeyKey);

    if (kIsWeb) {
      final factory = databaseFactoryWeb;
      await factory.deleteDatabase(_dbName);
    } else {
      final factory = databaseFactoryIo;
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = path.join(appDocDir.path, _dbName);
      await factory.deleteDatabase(dbPath);
    }
  }
}
