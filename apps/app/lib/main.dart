import 'package:flutter/widgets.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_drift/ndk_drift.dart';
import 'package:ndk_flutter/ndk_flutter.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'src/app.dart';
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
  final vaults = await Vaults.load(
    ndk: ndk,
    engine: SyncEngine(ndk, store: SembastSyncStore(await openSyncDatabase())),
    storage: VaultStorage(),
  );
  runApp(SubmarineApp(vaults: vaults));
}
