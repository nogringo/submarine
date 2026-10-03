import 'dart:io';

import 'package:ndk/ndk.dart';
import 'package:ndk_sqlite3/ndk_sqlite3.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'cli_exception.dart';
import 'sqlite_sync_store.dart';

class VaultSession {
  VaultSession({
    required String privateKey,
    required List<String> relays,
    required Directory cacheDirectory,
  }) : _database = _openDatabase(cacheDirectory) {
    _cache = SqliteCacheManager(_database);
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
  final Database _database;
  late final SqliteCacheManager _cache;
  late final Ndk ndk;
  late final Vault vault;

  /// Items not in the trash, once the relays sent what changed since the last
  /// run.
  Future<List<Item>> syncedItems() async {
    // Coverage from the last run is never fresh enough to skip the relays.
    final engine = SyncEngine(
      ndk,
      store: SqliteSyncStore(_database),
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
    }
  }

  Future<void> close() async {
    await ndk.destroy();
    await _cache.close();
  }
}

Database _openDatabase(Directory directory) {
  directory.createSync(recursive: true);
  return sqlite3.open(p.join(directory.path, 'ndk_cache.db'))
    // Another submarine process may be writing.
    ..execute('PRAGMA busy_timeout = 5000')
    ..execute('PRAGMA journal_mode = WAL')
    ..execute('PRAGMA synchronous = NORMAL');
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
