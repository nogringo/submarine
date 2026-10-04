import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:ndk/ndk.dart' show Nip01Event;
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'vault_storage.dart';

/// A vault of this device, kept synced from its relays while the app runs.
/// Its items are read from the ndk cache again whenever the sync moves on, or
/// another device publishes a change.
class VaultController extends ChangeNotifier {
  VaultController({
    required this.record,
    required this.vault,
    required SyncEngine engine,
  }) : _engine = engine {
    _handle = vault.sync(engine);
    // Replays the current status, which triggers the first read.
    _statuses = engine.watchStatus(_handle).listen(_onStatus);
    subscribe();
  }

  final VaultRecord record;
  final Vault vault;
  final SyncEngine _engine;
  late final SyncHandle _handle;
  late final StreamSubscription<SyncRequestStatus> _statuses;
  StreamSubscription<Nip01Event>? _live;

  String get pubkey => vault.signer.getPublicKey();
  String get name => record.name;
  Color get color => record.color;

  /// Every item, trash included, sorted by name.
  List<Item> get items => _items;
  List<Item> _items = const [];

  /// Whether [items] were read from the cache yet.
  bool get loaded => _loaded;
  var _loaded = false;

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

  /// Sends the unsent changes and fetches what changed on the relays now,
  /// rather than at the next pass.
  Future<void> sync() => Future.wait([
    vault.push().then((_) => _checkUnsent()),
    _engine.refresh(_handle),
  ]);

  /// Shows what other devices change the moment they publish it, until
  /// [unsubscribe].
  void subscribe() =>
      _live ??= vault.subscribe().listen((_) => unawaited(_reload()));

  Future<void> unsubscribe() async {
    final live = _live;
    _live = null;
    await live?.cancel();
  }

  /// Saved once in the ndk cache, then sent to the relays.
  Future<Item> createItem(Cipher cipher) => _write(vault.createItem(cipher));

  Future<Item> updateItem(Item item, Cipher cipher) =>
      _write(vault.updateItem(item, cipher));

  Future<Item> _write(Future<Envelope> saving) async {
    // The single version a write leaves is the item, as a read would find it.
    final item = Item([await saving]);
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
        final items = await vault.items();
        final lastSync = await vault.lastSync(_engine);
        if (_disposed) return;
        _items = items..sort(compareByName);
        _lastSync = lastSync;
        _loaded = true;
        notifyListeners();
        await _checkUnsent();
      } while (_reloadAgain);
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'submarine',
          context: ErrorDescription('while reading the vault $pubkey'),
        ),
      );
    } finally {
      _reloading = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _unsentCheck?.cancel();
    unawaited(_statuses.cancel());
    unawaited(unsubscribe());
    _engine.release(_handle);
    super.dispose();
  }
}

int compareByName(Item a, Item b) {
  final byName = a.cipher.name.toLowerCase().compareTo(
    b.cipher.name.toLowerCase(),
  );
  return byName != 0 ? byName : a.id.compareTo(b.id);
}
