import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage(
  // The data protection keychain needs a provisioning profile.
  mOptions: MacOsOptions(usesDataProtectionKeychain: false),
);
