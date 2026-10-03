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
    _engine = SyncEngine(
      ndk,
      store: SqliteSyncStore(_database),
      // A sync is asked for explicitly, so it always goes to the relays.
      maxStaleness: Duration.zero,
    );
  }

  /// Holds the ndk cache and the sync engine's coverage of it, which only make
  /// sense together.
  final Database _database;
  late final SqliteCacheManager _cache;
  late final Ndk ndk;
  late final Vault vault;
  late final SyncEngine _engine;

  /// Fetches from the relays what changed since the last sync.
  Future<void> sync() async {
    final handle = vault.sync(_engine);
    _engine.start();
    final status = await _engine
        .watchStatus(handle)
        .firstWhere(
          (status) =>
              status.phase == SyncRequestPhase.synced ||
              status.phase == SyncRequestPhase.failed,
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () =>
              throw CliException('Syncing failed: timed out after 30 s.'),
        );
    if (status.phase == SyncRequestPhase.failed) {
      throw CliException(
        'Syncing failed: no answer from ${vault.relays.join(', ')}.',
      );
    }
  }

  Future<DateTime?> lastSync() => vault.lastSync(_engine);

  /// Items as of the last [sync], trash included. Never goes to the relays.
  Future<List<Item>> items() async {
    if (await lastSync() == null) {
      throw CliException(
        'The vault was never synced. Run `submarine sync` first.',
      );
    }
    return vault.items();
  }

  Future<void> close() async {
    await _engine.dispose();
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
