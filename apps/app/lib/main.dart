import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_drift/ndk_drift.dart';
import 'package:ndk_flutter/ndk_flutter.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'src/app.dart';
import 'src/lock/app_lock.dart';
import 'src/storage_error_app.dart';
import 'src/sync/sync_database.dart';
import 'src/vaults/vault_storage.dart';
import 'src/vaults/vaults.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  final engine = SyncEngine(
    ndk,
    store: SembastSyncStore(await openSyncDatabase()),
  );
  await _start(ndk, engine);
}

/// Reads the secure storage before anything starts, so that a failed read
/// can be tried again from scratch.
Future<void> _start(Ndk ndk, SyncEngine engine) async {
  try {
    final lock = await AppLock.load();
    final vaults = await Vaults.load(
      ndk: ndk,
      engine: engine,
      storage: VaultStorage(),
    );
    runApp(SubmarineApp(vaults: vaults, lock: lock));
  } on PlatformException catch (error) {
    runApp(StorageErrorApp(error: error, onRetry: () => _start(ndk, engine)));
  }
}
