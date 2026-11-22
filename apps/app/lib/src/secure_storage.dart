import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _thisDeviceOnly = KeychainAccessibility.unlocked_this_device;

/// On Android, an error would otherwise erase every vault key in silence. On
/// iOS and macOS, a backup would otherwise carry the keys to another device.
const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(resetOnError: false),
  iOptions: IOSOptions(accessibility: _thisDeviceOnly),
  mOptions: MacOsOptions(accessibility: _thisDeviceOnly),
);

const _keptOnDeviceKey = 'thisDeviceOnly';

/// Writes again, once, what an earlier version kept in keychain entries that
/// backups carry, for the keychain to keep it on this device only.
Future<void> keepSecureStorageOnDevice() async {
  if (kIsWeb ||
      !const {
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      }.contains(defaultTargetPlatform) ||
      await secureStorage.read(key: _keptOnDeviceKey) != null) {
    return;
  }
  for (final MapEntry(:key, :value)
      in (await secureStorage.readAll()).entries) {
    await secureStorage.write(key: key, value: value);
  }
  await secureStorage.write(key: _keptOnDeviceKey, value: 'true');
}
