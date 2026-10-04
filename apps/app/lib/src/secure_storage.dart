import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// TODO: on Android, set resetOnError: false so that a Keystore error stops
// erasing every vault key in silence, show that error from Vaults.load, and
// leave this storage out of Auto Backup, whose restore cannot be decrypted.
const secureStorage = FlutterSecureStorage();
