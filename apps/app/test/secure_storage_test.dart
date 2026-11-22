import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:submarine/src/secure_storage.dart';

/// The values of the mock storage, which tell what it was asked to write.
class _Values extends MapBase<String, String> {
  _Values(this._values);

  final Map<String, String> _values;
  final written = <String>[];

  @override
  String? operator [](Object? key) => _values[key];

  @override
  void operator []=(String key, String value) {
    written.add(key);
    _values[key] = value;
  }

  @override
  void clear() => _values.clear();

  @override
  Iterable<String> get keys => _values.keys;

  @override
  String? remove(Object? key) => _values.remove(key);
}

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
    test('on ${platform.name}, writes every entry again once', () async {
      debugDefaultTargetPlatformOverride = platform;
      final values = _Values({'vaults': 'encrypted', 'vaultsKey': 'key'});
      FlutterSecureStorage.setMockInitialValues(values);

      await keepSecureStorageOnDevice();
      await keepSecureStorageOnDevice();

      expect(values.written, ['vaults', 'vaultsKey', 'thisDeviceOnly']);
      expect(values['vaults'], 'encrypted');
      expect(values['vaultsKey'], 'key');
    });
  }

  test('leaves the storage of the other platforms as it is', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final values = _Values({'vaults': 'encrypted'});
    FlutterSecureStorage.setMockInitialValues(values);

    await keepSecureStorageOnDevice();

    expect(values.written, isEmpty);
  });
}
