import 'dart:async';

import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'core.dart';
import 'vaults.dart';

/// Keeps the vaults of this device synced from their relays, download only,
/// from [start] to [stop]: while the popup is open. Reads their items any time.
class VaultSync {
  VaultSync({
    required this.ndk,
    required this._database,
    required this._vaults,
    required this.onChanged,
    this.onSending = _sendsQuietly,
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

  /// Tells while changes are being sent, for the background to stay awake.
  final void Function(bool sending) onSending;

  /// How long the changes saved or pushed keep being sent once the popup
  /// closed: ndk tries again after 5, 15 and 60 seconds. The next opening of
  /// the popup sends what is left.
  static const sendingTime = Duration(minutes: 2);

  final _synced = <String, _SyncedVault>{};
  var _running = false;
  var _closed = false;
  var _sending = false;
  var _sendingUntil = DateTime(0);
  Timer? _unsentCheck;

  /// Sends the changes no relay accepted yet too.
  Future<void> start() async {
    _running = true;
    _engine.start();
    await update();
    unawaited(_push());
  }

  Future<void> stop() async {
    _running = false;
    await Future.wait([
      _engine.stop(),
      for (final vault in _synced.values) vault.pause(),
    ]);
  }

  /// Stops for good, and lets go of the vaults: their keys and the items they
  /// opened, as locking does.
  Future<void> close() async {
    _running = false;
    _closed = true;
    _unsentCheck?.cancel();
    _setSending(false);
    for (final synced in _synced.values) {
      await synced.close();
      ndk.accounts.removeAccount(pubkey: synced.pubkey);
    }
    _synced.clear();
    await _engine.dispose();
    await ndk.destroy();
    await _database.close();
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

  /// Sends the changes of the vault [pubkey], or of every vault, and syncs it
  /// at once rather than at the next pass, as the app's sync button does.
  Future<void> syncNow({String? pubkey}) => Future.wait([
    for (final vault in _synced.values)
      if (pubkey == null || vault.pubkey == pubkey) vault.syncNow(),
    _push(pubkey: pubkey),
  ]);

  /// Sends again the changes of the vault [pubkey], or of every vault, that no
  /// relay accepted yet.
  Future<void> _push({String? pubkey}) async {
    _sendingUntil = DateTime.now().add(sendingTime);
    _setSending(true);
    await Future.wait([
      for (final vault in _synced.values)
        if (pubkey == null || vault.pubkey == pubkey) vault.push(),
    ]);
    await _checkUnsent();
  }

  /// Looks again every 5 seconds while changes wait, as the app does: nothing
  /// tells when ndk sent them.
  Future<void> _checkUnsent() async {
    var unsent = 0;
    for (final vault in [..._synced.values]) {
      unsent += await vault.checkUnsent();
    }
    if (_closed) return;
    _unsentCheck?.cancel();
    final sending =
        unsent > 0 && (_running || DateTime.now().isBefore(_sendingUntil));
    if (sending) {
      _unsentCheck = Timer(
        const Duration(seconds: 5),
        () => unawaited(_checkUnsent()),
      );
    }
    _setSending(sending);
  }

  void _setSending(bool sending) {
    if (sending == _sending) return;
    _sending = sending;
    onSending(sending);
  }

  /// Removes the vault of [record] from this device, see [Vault.forget]: its
  /// relays keep it. Remove its record first, for nothing to open it again.
  Future<void> forget(VaultRecord record) async {
    final synced = _open(record);
    _synced.remove(synced.pubkey);
    await synced.close();
    ndk.accounts.removeAccount(pubkey: synced.pubkey);
    await synced.vault.forget(_engine);
  }

  /// Where the sync of each vault stands, for those [start] got to.
  List<Map<String, Object?>> states() => [
    for (final vault in _synced.values)
      {
        'pubkey': vault.pubkey,
        'phase': vault.phase.name,
        'lastSync': vault.lastSync?.toIso8601String(),
        'unsent': vault.unsent,
      },
  ];

  /// The items of the vault [pubkey], or of every vault, that [filter] keeps
  /// as the app's filters do, by name, those [query] finds as the app's search
  /// does, and only the logins for the page at [url] when given. Those opened
  /// so far: the sync opens what comes in.
  ///
  /// [filter] is `all`, the default, `favorites`, `trash`, or a type of
  /// Bitwarden's. Only the trash keeps the items in it.
  Future<List<Map<String, Object?>>> items({
    String? pubkey,
    String query = '',
    String? url,
    Object filter = 'all',
  }) async {
    bool keeps(Cipher cipher) => switch (filter) {
      'trash' => cipher.isDeleted,
      _ when cipher.isDeleted => false,
      'all' => true,
      'favorites' => cipher.favorite,
      final int type => cipher.type.value == type,
      _ => throw CoreException('unknownFilter', '$filter'),
    };
    final vaultOf = {
      for (final vault in await _vaultsOf(pubkey))
        for (final item in await vault.vault.openedItems())
          if (keeps(item.cipher)) item: vault.pubkey,
    };
    final searched = searchItems(vaultOf.keys, query);
    final found = (url == null ? searched : itemsForUrl(searched, url))
      ..sort(compareItemsByName);
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

  /// The types of the items of the vault [pubkey], or of every vault, trash
  /// left out: those worth a filter.
  Future<List<int>> itemTypes({String? pubkey}) async => {
    for (final vault in await _vaultsOf(pubkey))
      for (final item in await vault.vault.openedItems())
        if (!item.cipher.isDeleted) item.cipher.type.value,
  }.toList();

  /// The item [id] of the vault [pubkey], its cipher in Bitwarden's JSON,
  /// in the trash or not, or null once gone. Its `base`, the versions it was
  /// read from, is what [updateItem] builds on.
  Future<Map<String, Object?>?> item({
    required String pubkey,
    required String id,
  }) async {
    for (final vault in await _vaultsOf(pubkey)) {
      for (final item in await vault.vault.openedItems()) {
        if (item.id == id) {
          return {
            'vault': pubkey,
            'id': id,
            'cipher': item.cipher.toJson(),
            'base': [for (final head in item.heads) head.toJson()],
          };
        }
      }
    }
    return null;
  }

  /// Saves [cipher], in Bitwarden's JSON, as a new item of the vault
  /// [pubkey]. Returns its id.
  Future<String> createItem({
    required String pubkey,
    required Map<String, dynamic> cipher,
  }) => _write(pubkey, (vault) async {
    final now = DateTime.now().toUtc();
    final created = Cipher.fromJson(cipher)
      ..creationDate ??= now
      ..revisionDate ??= now;
    return (await vault.createItem(created)).id;
  });

  /// Saves [cipher] as the next version of the [base] an [item] read gave,
  /// rather than of the versions synced since: as in the app, saving over
  /// another device's change keeps both, as a conflict, instead of losing it.
  Future<void> updateItem({
    required String pubkey,
    required List<Object?> base,
    required Map<String, dynamic> cipher,
  }) => _write(
    pubkey,
    (vault) => vault.updateItem(
      Item([
        for (final head in base)
          Envelope.fromJson(head as Map<String, dynamic>),
      ]),
      Cipher.fromJson(cipher),
    ),
  );

  /// Adds the item [id] of the vault [pubkey] to the favorites, or takes it
  /// out.
  Future<void> setFavorite({
    required String pubkey,
    required String id,
    required bool favorite,
  }) => _change(
    pubkey,
    id,
    (vault, item) => vault.updateItem(
      item,
      Cipher.fromJson(item.current.data)..favorite = favorite,
    ),
  );

  /// Moves the item [id] of the vault [pubkey] to the trash, where it stays
  /// until [restoreItem] or [deleteItem].
  Future<void> trashItem({required String pubkey, required String id}) =>
      _change(pubkey, id, (vault, item) => vault.trashItem(item));

  Future<void> restoreItem({required String pubkey, required String id}) =>
      _change(pubkey, id, (vault, item) => vault.restoreItem(item));

  /// Deletes the item [id] of the vault [pubkey] for good, see
  /// [Vault.deleteItem].
  Future<void> deleteItem({required String pubkey, required String id}) =>
      _change(pubkey, id, (vault, item) => vault.deleteItem(item));

  Future<void> _change(
    String pubkey,
    String id,
    Future<void> Function(Vault vault, Item item) change,
  ) => _write(pubkey, (vault) async {
    final item = (await vault.openedItems())
        .where((item) => item.id == id)
        .firstOrNull;
    if (item == null) throw CoreException('itemNotFound');
    await change(vault, item);
  });

  Future<T> _write<T>(
    String pubkey,
    Future<T> Function(Vault vault) write,
  ) async {
    final vaults = await _vaultsOf(pubkey);
    if (vaults.isEmpty) throw CoreException('vaultNotFound');
    final result = await vaults.single.write(write);
    onChanged();
    _sendingUntil = DateTime.now().add(sendingTime);
    unawaited(_checkUnsent());
    return result;
  }

  /// The vault [pubkey], none once removed, or every vault.
  Future<List<_SyncedVault>> _vaultsOf(String? pubkey) async => [
    for (final record in await _vaults.records())
      if (_open(record) case final vault
          when pubkey == null || vault.pubkey == pubkey)
        vault,
  ];

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

void _sendsQuietly(bool sending) {}

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

  /// Changes saved on this device that no relay accepted yet, as last counted
  /// by [checkUnsent].
  var unsent = 0;

  /// Counts the changes no relay accepted yet, and tells once their count
  /// changed.
  Future<int> checkUnsent() async {
    try {
      final count = (await vault.unsent()).length;
      if (count != unsent && !_closed) {
        unsent = count;
        _onChanged();
      }
    } catch (error, stack) {
      print('Counting the changes of $pubkey not sent failed: $error\n$stack');
    }
    return unsent;
  }

  Future<void> push() async {
    try {
      await vault.push();
    } catch (error, stack) {
      print('Sending the changes of $pubkey failed: $error\n$stack');
    }
  }

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

  var _closed = false;

  Future<void> _writing = Future.value();

  /// Runs [write] once the writes asked before it are saved: built on the
  /// same version, two changes would fork an item.
  Future<T> write<T>(Future<T> Function(Vault vault) write) {
    final done = _writing.then((_) => write(vault));
    _writing = done.then((_) {}, onError: (_) {});
    return done;
  }

  /// Stops for good, as the sync would fill the cache again.
  Future<void> close() async {
    _closed = true;
    await pause();
    await _statuses?.cancel();
    if (_handle case final handle?) _engine.release(await handle);
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
    if (_closed) return;
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
    if (_handle != next || _closed) return;
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
