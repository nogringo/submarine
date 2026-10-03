import 'dart:io';

import 'package:ndk/ndk.dart';
import 'package:ndk_sqlite3/ndk_sqlite3.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:path/path.dart' as p;
import 'package:sembast/sembast_io.dart' show databaseFactoryIo;
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'cli_exception.dart';

class VaultSession {
  VaultSession({
    required String privateKey,
    required List<String> relays,
    required this.cacheDirectory,
  }) : _cache = _openCache(cacheDirectory) {
    ndk = _quietNdk(_cache);
    final signer = const Bip340EventSignerFactory().create(
      privateKey: privateKey,
    );
    ndk.accounts.addAccount(
      pubkey: signer.getPublicKey(),
      type: AccountType.privateKey,
      signer: signer,
    );
    vault = Vault(ndk: ndk, signer: signer, relays: relays);
  }

  /// Holds the ndk cache and the sync engine's coverage of it, which only make
  /// sense together.
  final Directory cacheDirectory;
  final SqliteCacheManager _cache;
  late final Ndk ndk;
  late final Vault vault;

  /// Items not in the trash, once the relays sent what changed since the last
  /// run.
  Future<List<Item>> syncedItems() async {
    final db = await databaseFactoryIo.openDatabase(
      p.join(cacheDirectory.path, 'sync.db'),
    );
    // Coverage from the last run is never fresh enough to skip the relays.
    final engine = SyncEngine(
      ndk,
      store: SembastSyncStore(db),
      maxStaleness: Duration.zero,
    );
    try {
      final handle = vault.sync(engine);
      engine.start();
      final status = await engine
          .watchStatus(handle)
          .firstWhere(
            (status) =>
                status.phase == SyncRequestPhase.synced ||
                status.phase == SyncRequestPhase.failed,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw CliException('Syncing the vault timed out.'),
          );
      if (status.phase == SyncRequestPhase.failed) {
        throw CliException('No relay answered: ${vault.relays.join(', ')}.');
      }
      return [
        for (final item in await vault.items())
          if (item.cipher.deletedDate == null) item,
      ];
    } finally {
      await engine.dispose();
      await db.close();
    }
  }

  Future<void> close() async {
    await ndk.destroy();
    await _cache.close();
  }
}

SqliteCacheManager _openCache(Directory directory) {
  directory.createSync(recursive: true);
  return SqliteCacheManager.open(p.join(directory.path, 'ndk_cache.db'));
}

Ndk _quietNdk(CacheManager cache) {
  // ndk applies NdkConfig.logLevel only after Cashu has logged its warning.
  Logger.setLogLevel(LogLevel.off);
  return Ndk(
    NdkConfig(
      eventVerifier: Bip340EventVerifier(),
      cache: cache,
      bootstrapRelays: [],
      logLevel: LogLevel.off,
    ),
  );
}
