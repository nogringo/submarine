import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:ndk/ndk.dart'
    show Nip01Event, PendingSignerRequest, SignerMethod;
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'signer_watch.dart';
import 'vault_storage.dart';

/// A vault of this device, kept synced from its relays while the app runs.
/// Its items are read from the ndk cache again whenever the sync moves on, or
/// another device publishes a change.
class VaultController extends ChangeNotifier {
  VaultController({
    required this._record,
    required this.vault,
    required this._engine,
    Duration signerPatience = defaultSignerPatience,
  }) : _signer = SignerWatch(
         vault.signer.pendingRequestsStream,
         patience: signerPatience,
       ) {
    unawaited(_readRelays().then((_) => fetchRelays()));
    subscribe();
    _signer.addListener(() {
      if (_signer.idle) _approvalUrl = null;
      notifyListeners();
    });
    unawaited(unlock());
  }

  final Vault vault;
  final SyncEngine _engine;
  final SignerWatch _signer;

  /// Holds the relays of the moment, replaced once they change.
  Future<SyncHandle>? _handle;
  Set<String>? _syncedRelays;
  StreamSubscription<SyncRequestStatus>? _statuses;
  StreamSubscription<Nip01Event>? _live;

  /// Changed through [Vaults.edit], which saves it.
  VaultRecord get record => _record;
  VaultRecord _record;

  set record(VaultRecord record) {
    _record = record;
    notifyListeners();
  }

  String get pubkey => vault.signer.getPublicKey();
  String get name => record.name;
  Color get color => record.color;

  /// Every item, trash included, sorted by name.
  List<Item> get items => _items;
  List<Item> _items = const [];

  /// Whether [items] were read from the cache yet, with what the signer had to
  /// open at the start.
  bool get loaded => _loaded;
  var _loaded = false;

  /// Whether the signer answered for what it had to open at the start.
  var _opened = false;

  /// Whether the signer has yet to open the vault, whose cache key it keeps
  /// sealed. Nothing shows until it does, see [unlock].
  bool get locked => vault.cache?.locked ?? false;

  /// Whether [unlock] waits for the signer.
  bool get unlocking => _unlocking;
  var _unlocking = false;

  /// What the signer seems to wait on the user for, see [SignerWatch].
  List<PendingSignerRequest> get signerRequests => _signer.waiting;

  bool get waitingForSigner => signerRequests.isNotEmpty;

  /// The page where the bunker asks the user to approve, while it waits.
  String? get approvalUrl => waitingForSigner ? _approvalUrl : null;
  String? _approvalUrl;

  set approvalUrl(String? url) {
    _approvalUrl = url;
    if (!_disposed) notifyListeners();
  }

  /// Whether a cancelled decryption keeps the versions from being asked to
  /// open, until [sync].
  var _openingHeld = false;

  /// Cancels [requests], whose actions fail. Asks the signer to open no
  /// version until [sync], as the next read would ask again.
  void cancelSignerRequests(Iterable<PendingSignerRequest> requests) {
    final ids = [for (final request in requests) request.id];
    _signer.cancelled(ids);
    if (requests.any(
      (request) => request.method == SignerMethod.nip44Decrypt,
    )) {
      _openingHeld = true;
    }
    ids.forEach(vault.signer.cancelRequest);
  }

  SyncRequestPhase get phase => _phase;
  var _phase = SyncRequestPhase.idle;

  /// Null until the vault reached a relay once.
  DateTime? get lastSync => _lastSync;
  DateTime? _lastSync;

  /// Changes saved on this device that no relay accepted yet. ndk keeps
  /// sending them in the background.
  int get unsent => _unsent;
  var _unsent = 0;
  Timer? _unsentCheck;

  /// The relays the vault lives on, null until read from the cache.
  RelayList? get relayList => _relayList;
  RelayList? _relayList;

  /// Whether [setRelayList] cannot replace a newer list: the newest one was
  /// looked for, and the vault reached a relay once.
  bool get relaysEditable => _relaysFetched && _lastSync != null;
  var _relaysFetched = false;

  /// The vault's Blossom servers, null until read from the cache.
  ServerList? get serverList => _serverList;
  ServerList? _serverList;

  /// Whether [setServerList] cannot replace a newer list, which comes with the
  /// sync from the relays [relaysEditable] waits for.
  bool get serversEditable => relaysEditable;

  /// Sends the unsent changes and fetches what changed on the relays now,
  /// rather than at the next pass. Asks the signer again for what it did not
  /// open.
  Future<void> sync() => Future.wait([
    unlock(),
    if (_openingHeld) _resumeOpening(),
    vault.push().then((_) => _checkUnsent()),
    if (_handle case final handle?) handle.then(_engine.refresh),
    fetchRelays(),
  ]);

  /// Fetches the relay list another device may have changed, and moves the
  /// sync to its relays.
  Future<void> fetchRelays() async {
    try {
      await vault.fetchRelayList();
      _relaysFetched = true;
    } catch (error, stack) {
      _report(error, stack, 'while fetching the relay list of the vault');
    }
    await _readRelays();
  }

  /// Saved once in the ndk cache, then sent to the relays. The relays it adds
  /// get a copy of the vault.
  Future<void> setRelayList(RelayList list) async {
    await vault.setRelayList(list);
    await _readRelays();
    unawaited(_checkUnsent());
  }

  /// Saved once in the ndk cache, then sent to the relays.
  Future<void> setServerList(ServerList list) async {
    await vault.setServerList(list);
    await _readServers();
    unawaited(_checkUnsent());
  }

  Future<void> _readServers() async {
    final ServerList list;
    try {
      list = await vault.currentServerList();
    } catch (error, stack) {
      _report(error, stack, 'while reading the server list of the vault');
      return;
    }
    if (_disposed ||
        (listEquals(list.public, _serverList?.public) &&
            listEquals(list.private, _serverList?.private))) {
      return;
    }
    _serverList = list;
    notifyListeners();
  }

  Future<void> _readRelays() async {
    final RelayList list;
    try {
      list = await vault.currentRelayList();
    } catch (error, stack) {
      _report(error, stack, 'while reading the relay list of the vault');
      return;
    }
    if (_disposed) return;
    _relayList = list;
    notifyListeners();
    if (setEquals(list.urls, _syncedRelays)) return;
    _syncedRelays = list.urls;
    final previous = _handle;
    final next = _handle = vault.sync(_engine);
    final handle = await next;
    // After the new handle: the same relays would otherwise drop their sync.
    if (previous != null) unawaited(previous.then(_engine.release));
    if (_disposed || _handle != next) return;
    unawaited(_statuses?.cancel());
    // Replays the current status, which triggers a read.
    _statuses = _engine.watchStatus(handle).listen(_onStatus);
  }

  /// Asks the signer to open the vault, unless it did.
  Future<void> unlock() async {
    if (!locked || _unlocking) return;
    _unlocking = true;
    notifyListeners();
    try {
      await vault.cache!.unlock();
    } finally {
      _unlocking = false;
      if (!_disposed) notifyListeners();
    }
    if (!locked) await _reload();
  }

  Future<void> _resumeOpening() {
    _openingHeld = false;
    return _reload();
  }

  /// Shows what other devices change the moment they publish it, until
  /// [unsubscribe].
  void subscribe() =>
      _live ??= vault.subscribe().listen((_) => unawaited(_reload()));

  Future<void> unsubscribe() async {
    final live = _live;
    _live = null;
    await live?.cancel();
  }

  /// Whether a change to [item] is being saved. Another change before it ends
  /// would fork the item.
  bool isSaving(Item item) => _saving.contains(item.id);
  final _saving = <String>{};

  /// Saved once in the ndk cache, then sent to the relays.
  Future<Item> createItem(Cipher cipher) => _write(vault.createItem(cipher));

  Future<Item> updateItem(Item item, Cipher cipher) =>
      _change(item, () => _write(vault.updateItem(item, cipher)));

  /// Saves [ciphers] as new items one after the other, and tells [onSaved]
  /// how many are saved after each. Reads the vault again once, at the end.
  Future<void> importItems(
    List<Cipher> ciphers, {
    ValueChanged<int>? onSaved,
  }) async {
    try {
      for (final (index, cipher) in ciphers.indexed) {
        await vault.createItem(cipher);
        onSaved?.call(index + 1);
      }
    } finally {
      unawaited(_reload());
    }
  }

  Future<Item> trashItem(Item item) =>
      _change(item, () => _write(vault.trashItem(item)));

  Future<Item> restoreItem(Item item) =>
      _change(item, () => _write(vault.restoreItem(item)));

  /// Deletes [item] for good, from the cache and from the relays.
  Future<void> deleteItem(Item item) => _change(item, () async {
    await vault.deleteItem(item);
    if (_disposed) return;
    _items = [
      for (final other in _items)
        if (other.id != item.id) other,
    ];
    notifyListeners();
    unawaited(_reload());
  });

  Future<T> _change<T>(Item item, Future<T> Function() change) async {
    _saving.add(item.id);
    notifyListeners();
    try {
      return await change();
    } finally {
      _saving.remove(item.id);
      if (!_disposed) notifyListeners();
    }
  }

  Future<Item> _write(Future<Envelope> saving) async {
    // The single version a write leaves is the item, as a read would find it.
    final item = Item([await saving]);
    // Closed by the lock while it saved.
    if (_disposed) return item;
    _items = [
      for (final other in _items)
        if (other.id != item.id) other,
      item,
    ]..sort(compareByName);
    notifyListeners();
    unawaited(_reload());
    return item;
  }

  /// Looks again while changes wait, as nothing tells when ndk sent them.
  Future<void> _checkUnsent() async {
    final unsent = (await vault.unsent()).length;
    if (_disposed) return;
    _unsentCheck?.cancel();
    if (unsent > 0) {
      _unsentCheck = Timer(
        const Duration(seconds: 5),
        () => unawaited(_checkUnsent()),
      );
    }
    if (unsent == _unsent) return;
    _unsent = unsent;
    notifyListeners();
  }

  void _onStatus(SyncRequestStatus status) {
    _phase = status.phase;
    notifyListeners();
    unawaited(_reload());
  }

  var _reloading = false;
  var _reloadAgain = false;
  var _disposed = false;

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
        final items = await vault.openedItems();
        final lastSync = await vault.lastSync(_engine);
        if (_disposed) return;
        _items = items..sort(compareByName);
        if (_lastSync == null && lastSync != null && _relaysFetched) {
          // Fetched before the vault ever reached a relay.
          _relaysFetched = false;
          unawaited(fetchRelays());
        }
        _lastSync = lastSync;
        _loaded = _opened;
        notifyListeners();
        // The signer opens the private servers too.
        if (!locked && !_openingHeld) {
          unawaited(_open());
          unawaited(_readServers());
        }
        await _checkUnsent();
      } while (_reloadAgain);
    } catch (error, stack) {
      _report(error, stack, 'while reading the vault');
    } finally {
      _reloading = false;
    }
  }

  /// Asks the signer for the versions never opened, without holding back
  /// those it opened before.
  Future<void> _open() async {
    try {
      final opened = await vault.open();
      if (_disposed) return;
      final first = !_opened;
      _opened = true;
      if (opened || first) unawaited(_reload());
    } catch (error, stack) {
      _report(error, stack, 'while opening the vault');
    }
  }

  void _report(Object error, StackTrace stack, String context) =>
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'submarine',
          context: ErrorDescription('$context $pubkey'),
        ),
      );

  /// Removes the vault from this device once disposed, see [Vault.forget].
  Future<void> forget() async {
    assert(_disposed);
    await _released;
    await vault.forget(_engine);
  }

  Future<void>? _released;

  @override
  void dispose() {
    _disposed = true;
    _unsentCheck?.cancel();
    unawaited(_statuses?.cancel());
    _signer.dispose();
    unawaited(unsubscribe());
    unawaited(_released = _handle?.then(_engine.release));
    super.dispose();
  }
}

int compareByName(Item a, Item b) {
  final byName = a.cipher.name.toLowerCase().compareTo(
    b.cipher.name.toLowerCase(),
  );
  return byName != 0 ? byName : a.id.compareTo(b.id);
}
