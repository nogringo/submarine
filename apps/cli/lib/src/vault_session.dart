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

  /// Fetches the vault's relay list, sends to its relays the changes none
  /// accepted yet, then fetches what changed since the last sync.
  Future<void> sync() async {
    await vault.fetchRelayList();
    final unsent = await vault.push();
    await _fetch();
    if (unsent.isNotEmpty) throw CliException(_unsentMessage(unsent));
  }

  /// Gives the cache and each of the vault's relays what it lacks, then
  /// fetches as [sync] does, which is what [lastSync] tells.
  Future<void> reconcile() async {
    final leftOut = await vault.reconcile();
    await _fetch();
    if (leftOut.isNotEmpty) throw CliException(_leftOutMessage(leftOut));
  }

  Future<void> _fetch() async {
    final handle = await vault.sync(_engine);
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
        'Syncing failed: no answer from ${(await vault.currentRelays()).join(', ')}.',
      );
    }
  }

  Future<DateTime?> lastSync() => vault.lastSync(_engine);

  /// Items as of the last [sync], trash included. Never goes to the relays.
  Future<List<Item>> items() async {
    await _ensureSynced();
    return vault.items();
  }

  /// The vault's relay list as of the last [sync], or the relays it starts on
  /// while it has none. Never goes to the relays.
  Future<RelayList> relayList() async {
    // Without the newest list, a change would replace it with an older one.
    await _ensureSynced();
    final list = await vault.relayList();
    if (list == null || (list.public.isEmpty && list.private.isEmpty)) {
      return RelayList(
        public: {
          for (final relay in vault.relays) relay: ReadWriteMarker.readWrite,
        },
      );
    }
    return list;
  }

  Future<void> _ensureSynced() async {
    if (await lastSync() == null) {
      throw CliException(
        'The vault was never synced. Run `submarine sync` first.',
      );
    }
  }

  /// The item [id], trash included, as of the last [sync].
  Future<Item> item(String id) async =>
      (await items()).where((item) => item.id == id).firstOrNull ??
      (throw CliException('Not found.'));

  Future<void> close() async {
    await _engine.dispose();
    await ndk.destroy();
    await _cache.close();
  }
}

String _unsentMessage(List<EventDeliverySnapshot> unsent) {
  final answers = {
    for (final delivery in unsent)
      for (final target in delivery.relayTargets)
        target.relayUrl: target.lastError ?? target.lastOkMessage ?? '',
  };
  final events = unsent.length == 1 ? '1 event' : '${unsent.length} events';
  return [
    'Syncing failed: no relay accepted $events, still saved locally:',
    for (final MapEntry(:key, :value) in answers.entries)
      '  $key: ${value.isEmpty ? 'no answer' : value}',
  ].join('\n');
}

String _leftOutMessage(Map<String, String> leftOut) {
  final relays = leftOut.length == 1 ? '1 relay' : '${leftOut.length} relays';
  return [
    'Syncing incomplete, $relays left out:',
    for (final MapEntry(:key, :value) in leftOut.entries) '  $key: $value',
  ].join('\n');
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
      // A command never waits for the relays: sync sends what is pending.
      pendingDeliveryRetriesEnabled: false,
    ),
  );
}
