import 'package:flutter/foundation.dart';

export 'sync_database_io.dart'
    if (dart.library.js_interop) 'sync_database_web.dart';

/// Split between debug and release like ndk_drift's cache: the sync coverage
/// must never outlive the cache it describes.
const syncDatabaseName = kDebugMode ? 'sync_engine_debug' : 'sync_engine';
