import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// On Android, an error would otherwise erase every vault key in silence.
const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(resetOnError: false),
);
