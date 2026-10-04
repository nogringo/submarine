import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../secure_storage.dart';

/// A vault opened on this device. Its name and color stay on the device:
/// someone the vault is shared with names it their own way.
class VaultRecord {
  const VaultRecord({
    required this.privateKey,
    required this.name,
    required this.color,
  });

  VaultRecord.fromJson(Map<String, dynamic> json)
    : privateKey = json['privateKey'] as String,
      name = json['name'] as String,
      color = Color(json['color'] as int);

  /// In hex.
  final String privateKey;
  final String name;
  final Color color;

  VaultRecord copyWith({String? name, Color? color}) => VaultRecord(
    privateKey: privateKey,
    name: name ?? this.name,
    color: color ?? this.color,
  );

  Map<String, dynamic> toJson() => {
    'privateKey': privateKey,
    'name': name,
    'color': color.toARGB32(),
  };
}

/// Keeps the vaults of this device, keys included, in its secure storage.
class VaultStorage {
  VaultStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? secureStorage;

  static const _key = 'vaults';

  final FlutterSecureStorage _storage;

  Future<List<VaultRecord>> read() async {
    final json = await _storage.read(key: _key);
    if (json == null) return [];
    return [
      for (final record in jsonDecode(json) as List)
        VaultRecord.fromJson(record as Map<String, dynamic>),
    ];
  }

  Future<void> write(List<VaultRecord> records) => _storage.write(
    key: _key,
    value: jsonEncode([for (final record in records) record.toJson()]),
  );
}
