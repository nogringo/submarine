import 'dart:async';

import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'vaults.dart';

/// Keeps the vaults of this device synced from their relays, download only,
/// from [start] to [stop]: while the popup is open. Reads their items any time.
class VaultSync {
  VaultSync({
    required this.ndk,
    required this._database,
    required this._vaults,
    required this.onChanged,
    this.relays = defaultVaultRelays,
    this.indexers = defaultIndexerRelays,
  }) : _engine = SyncEngine(
         ndk,
         store: SembastSyncStore(_database),
         // Each opening of the popup goes to the relays, and the live
         // subscription brings the rest while it stays open.
         maxStaleness: Duration.zero,
         minRevisitPeriod: const Duration(minutes: 5),
       );

  final Ndk ndk;
  final Database _database;
  final Vaults _vaults;
  final SyncEngine _engine;

  /// Where a vault lives until it has a relay list.
  final List<String> relays;

  /// Where a vault's relay list is looked for too.
  final List<String> indexers;

  /// Tells that what [states] returns, or what the vaults hold, changed.
  final void Function() onChanged;

  final _synced = <String, _SyncedVault>{};
  var _running = false;

  Future<void> start() async {
    _running = true;
    _engine.start();
    await update();
  }

  Future<void> stop() async {
    _running = false;
    await Future.wait([
      _engine.stop(),
      for (final vault in _synced.values) vault.pause(),
    ]);
  }

  /// Syncs the vaults opened since [start] too.
  Future<void> update() async {
    if (!_running) return;
    final records = await _vaults.records();
    if (!_running) return;
    for (final record in records) {
      _open(record).resume();
    }
  }

  /// Syncs the vault [pubkey], or every vault, at once rather than at the next
  /// pass, as the app's sync button does.
  Future<void> syncNow({String? pubkey}) => Future.wait([
    for (final vault in _synced.values)
      if (pubkey == null || vault.pubkey == pubkey) vault.syncNow(),
  ]);

  /// Where the sync of each vault stands, for those [start] got to.
  List<Map<String, Object?>> states() => [
    for (final vault in _synced.values)
      {
        'pubkey': vault.pubkey,
        'phase': vault.phase.name,
        'lastSync': vault.lastSync?.toIso8601String(),
      },
  ];

  /// The items of the vault [pubkey], or of every vault, trash left out, by
  /// name, those [query] finds as the app's search does. Those opened so far:
  /// the sync opens what comes in.
  Future<List<Map<String, Object?>>> items({
    String? pubkey,
    String query = '',
  }) async {
    final vaults = [
      for (final record in await _vaults.records())
        if (_open(record) case final vault
            when pubkey == null || vault.pubkey == pubkey)
          vault,
    ];
    final vaultOf = {
      for (final vault in vaults)
        for (final item in await vault.vault.openedItems())
          if (!item.cipher.isDeleted) item: vault.pubkey,
    };
    final found = searchItems(vaultOf.keys, query)..sort(compareItemsByName);
    return [
      for (final item in found)
        {
          'vault': vaultOf[item],
          'id': item.id,
          'type': item.cipher.type.value,
          'name': item.cipher.name,
          'subtitle': item.cipher.subtitle,
          'copies': _rowCopy(item.cipher),
        },
    ];
  }

  /// The item [id] of the vault [pubkey], its cipher in Bitwarden's JSON, or
  /// null once in the trash or gone.
  Future<Map<String, Object?>?> item({
    required String pubkey,
    required String id,
  }) async {
    for (final record in await _vaults.records()) {
      final vault = _open(record);
      if (vault.pubkey != pubkey) continue;
      for (final item in await vault.vault.openedItems()) {
        if (item.id == id && !item.cipher.isDeleted) {
          return {'vault': pubkey, 'id': id, 'cipher': item.cipher.toJson()};
        }
      }
    }
    return null;
  }

  _SyncedVault _open(VaultRecord record) {
    final signer = ndk.config.eventSignerFactory.create(
      privateKey: record.privateKey,
    );
    final pubkey = signer.getPublicKey();
    if (_synced[pubkey] case final synced?) return synced;
    // Vault.sync authenticates as the vault, which ndk must know.
    ndk.accounts.addAccount(
      pubkey: pubkey,
      type: AccountType.privateKey,
      signer: signer,
    );
    return _synced[pubkey] = _SyncedVault(
      Vault(
        ndk: ndk,
        signer: signer,
        relays: relays,
        indexers: indexers,
        cache: VersionCache(
          SembastVersionStore(_database, pubkey),
          record.cacheKey,
        ),
      ),
      _engine,
      onChanged,
    );
  }
}

/// What the copy button of an item's row copies, as in the app: the secret a
/// login or a card is opened for.
String? _rowCopy(Cipher cipher) {
  bool present(String? value) => value != null && value.trim().isNotEmpty;
  if (present(cipher.login?.password)) return 'password';
  if (present(cipher.card?.number)) return 'number';
  return null;
}

/// A vault synced from its relays, and live while resumed. Opens what comes in
/// as it comes, for its items to show at once.
class _SyncedVault {
  _SyncedVault(this.vault, this._engine, this._onChanged);

  final Vault vault;
  final SyncEngine _engine;
  final void Function() _onChanged;

  String get pubkey => vault.signer.getPublicKey();

  var phase = SyncRequestPhase.idle;

  /// Null until the vault reached a relay once.
  DateTime? lastSync;

  /// Holds the relays of the moment, replaced once they change.
  Future<SyncHandle>? _handle;
  Set<String>? _syncedRelays;
  StreamSubscription<SyncRequestStatus>? _statuses;
  StreamSubscription<Nip01Event>? _live;

  void resume() {
    if (_live != null) return;
    _live = vault.subscribe().listen((_) => unawaited(_reload()));
    unawaited(_follow().then((_) => _fetchRelays()));
  }

  Future<void> pause() async {
    final live = _live;
    _live = null;
    await live?.cancel();
  }

  /// Does nothing while paused.
  Future<void> syncNow() async {
    if (_live == null) return;
    await Future.wait([
      if (_handle case final handle?) handle.then(_engine.refresh),
      _fetchRelays(),
    ]);
  }

  /// Fetches the relay list another device may have changed.
  Future<void> _fetchRelays() async {
    try {
      await vault.fetchRelayList();
    } catch (error, stack) {
      print('Fetching the relay list of $pubkey failed: $error\n$stack');
    }
    await _follow();
  }

  /// Moves the sync to the relays the vault lives on, once they changed.
  Future<void> _follow() async {
    final relays = (await vault.currentRelays()).toSet();
    if (_syncedRelays case final synced?
        when synced.length == relays.length && synced.containsAll(relays)) {
      return;
    }
    _syncedRelays = relays;
    final previous = _handle;
    final next = _handle = vault.sync(_engine);
    final handle = await next;
    // After the new handle: the same relays would otherwise drop their sync.
    if (previous != null) unawaited(previous.then(_engine.release));
    if (_handle != next) return;
    unawaited(_statuses?.cancel());
    // Replays the current status, which triggers a read.
    _statuses = _engine.watchStatus(handle).listen((status) {
      phase = status.phase;
      unawaited(_reload());
    });
  }

  var _reloading = false;
  var _reloadAgain = false;

  /// Folds the reloads asked for while one runs into a single next one.
  Future<void> _reload() async {
    if (_reloading) {
      _reloadAgain = true;
      return;
    }
    _reloading = true;
    try {
      do {
        _reloadAgain = false;
        await vault.open();
        lastSync = await vault.lastSync(_engine);
        _onChanged();
      } while (_reloadAgain);
    } catch (error, stack) {
      print('Reading the vault $pubkey failed: $error\n$stack');
    } finally {
      _reloading = false;
    }
  }
}
