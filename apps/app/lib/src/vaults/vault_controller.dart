import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'vault_storage.dart';

/// A vault of this device, kept synced from its relays while the app runs.
/// Its items are read from the ndk cache again whenever the sync moves on.
class VaultController extends ChangeNotifier {
  VaultController({
    required this.record,
    required this.vault,
    required SyncEngine engine,
  }) : _engine = engine {
    _handle = vault.sync(engine);
    // Replays the current status, which triggers the first read.
    _statuses = engine.watchStatus(_handle).listen(_onStatus);
  }

  final VaultRecord record;
  final Vault vault;
  final SyncEngine _engine;
  late final SyncHandle _handle;
  late final StreamSubscription<SyncRequestStatus> _statuses;

  String get pubkey => vault.signer.getPublicKey();
  String get name => record.name;
  Color get color => record.color;

  /// Neither in the trash nor archived, sorted by name.
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

  /// Fetches what changed on the relays now, rather than at the next pass.
  Future<void> sync() => _engine.refresh(_handle);

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
        _items = [
          for (final item in items)
            if (!item.cipher.isDeleted && !item.cipher.isArchived) item,
        ]..sort(compareByName);
        _lastSync = lastSync;
        _loaded = true;
        notifyListeners();
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
    unawaited(_statuses.cancel());
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
