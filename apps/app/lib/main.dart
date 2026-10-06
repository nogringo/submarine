import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_drift/ndk_drift.dart';
import 'package:ndk_flutter/ndk_flutter.dart';
import 'package:sembast/sembast.dart' show Database;
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'src/app.dart';
import 'src/clipboard.dart';
import 'src/lock/app_lock.dart';
import 'src/screen_capture.dart';
import 'src/storage_error_app.dart';
import 'src/theme/appearance.dart';
import 'src/sync/sync_database.dart';
import 'src/vaults/vault_storage.dart';
import 'src/vaults/vaults.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Otherwise Android paints its window background behind the navigation bar.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final ndk = Ndk(
    NdkConfig(
      eventVerifier: NdkEventVerifier(),
      eventSignerFactory: const NdkEventSignerFactory(),
      cache: await DriftCacheManager.create(),
      // The vaults' relays only: no bootstrap relay learns about the app.
      bootstrapRelays: [],
      logLevel: LogLevel.warning,
    ),
  );
  final database = await openSyncDatabase();
  final engine = SyncEngine(ndk, store: SembastSyncStore(database));
  await _start(ndk, engine, database);
}

/// Reads the secure storage before anything starts, so that a failed read
/// can be tried again from scratch.
Future<void> _start(Ndk ndk, SyncEngine engine, Database database) async {
  try {
    final lock = await AppLock.load();
    final appearance = await Appearance.load();
    final clipboard = await AppClipboard.load();
    final screenCapture = await ScreenCapture.load();
    final vaults = await Vaults.load(
      ndk: ndk,
      engine: engine,
      storage: VaultStorage(),
      database: database,
    );
    runApp(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
  } on PlatformException catch (error) {
    runApp(
      StorageErrorApp(
        error: error,
        onRetry: () => _start(ndk, engine, database),
      ),
    );
  }
}
