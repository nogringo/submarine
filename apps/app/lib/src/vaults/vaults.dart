import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_flutter/ndk_flutter.dart'
    show Nip07EventSigner, Nip55EventSigner, Nip55Signer;
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast.dart'
    show Database, SembastStoreRefExtension, StoreRef;
import 'package:sembast/utils/database_utils.dart' show getNonEmptyStoreNames;
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import '../items/item_filter.dart';
import 'signer_watch.dart';
import 'vault_controller.dart';
import 'vault_storage.dart';
import 'version_store.dart';

enum VaultColor {
  blue(Color(0xFF2F6FD0)),
  orange(Color(0xFFB95A22)),
  green(Color(0xFF2A7F61)),
  purple(Color(0xFF8A4FBF)),
  pink(Color(0xFFB8336A)),
  gray(Color(0xFF5B6B7A));

  const VaultColor(this.color);

  final Color color;
}

/// Stands for every vault where a vault's public key is expected.
const allVaultsId = 'all';

class VaultItem {
  const VaultItem(this.vault, this.item);

  final VaultController vault;
  final Item item;
}

/// The vaults of this device.
class Vaults extends ChangeNotifier {
  Vaults._({
    required this.ndk,
    required this.engine,
    required this.relays,
    required this.indexers,
    required this._storage,
    required this._database,
    required this._signerPatience,
  });

  /// Closed until [open]. Each vault keeps the versions it opened in
  /// [database]. A signer silent for [signerPatience] seems to wait on the
  /// user.
  static Future<Vaults> load({
    required Ndk ndk,
    required SyncEngine engine,
    required VaultStorage storage,
    required Database database,
    List<String> relays = defaultVaultRelays,
    List<String> indexers = defaultIndexerRelays,
    Duration signerPatience = defaultSignerPatience,
  }) async {
    final vaults = Vaults._(
      ndk: ndk,
      engine: engine,
      relays: relays,
      indexers: indexers,
      storage: storage,
      database: database,
      signerPatience: signerPatience,
    );
    engine.start();
    return vaults;
  }

  static Vaults of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VaultsScope>()!.notifier!;

  final Ndk ndk;
  final SyncEngine engine;
  final List<String> relays;
  final List<String> indexers;
  final VaultStorage _storage;
  final Database _database;
  final Duration _signerPatience;
  final _vaults = <VaultController>[];

  List<VaultController> get all => List.unmodifiable(_vaults);
  bool get isEmpty => _vaults.isEmpty;

  /// Whether the lock closed the vaults: none is in memory, keys and items
  /// included, and none syncs. [all] is then empty, whatever the device holds.
  bool get closed => _key == null;

  /// The key of the device, while open.
  SymmetricCryptoKey? _key;

  /// Changes on each [open] and [close], for an opening to know it was closed
  /// meanwhile.
  var _generation = 0;

  /// Opens the vaults saved on this device, encrypted with [key], and starts
  /// syncing them. Throws a [VaultsUnreadableException] when [key] does not
  /// open them.
  Future<void> open(SymmetricCryptoKey key) async {
    if (!closed) return;
    final generation = ++_generation;
    final records = await _storage.read(key);
    if (generation != _generation) return;
    _key = key;
    for (final record in records) {
      _open(record);
    }
    notifyListeners();
  }

  /// Removes every vault from this device while closed, with what they opened
  /// and the events of the cache: what a forgotten lock password leaves.
  Future<void> forget() async {
    assert(closed);
    await _storage.delete();
    await ndk.config.cache.removeAllEvents();
    final stores = getNonEmptyStoreNames(_database).toList();
    await _database.transaction((transaction) async {
      for (final name in stores) {
        await StoreRef<Object?, Object?>(name).drop(transaction);
      }
    });
  }

  /// Drops every vault, with its signer and what it opened, until [open].
  void close() {
    _generation++;
    if (closed) return;
    _key = null;
    for (final vault in _vaults) {
      vault.dispose();
      ndk.accounts.removeAccount(pubkey: vault.pubkey);
      unawaited(vault.vault.signer.dispose());
    }
    _vaults.clear();
    notifyListeners();
  }

  VaultController? byPubkey(String pubkey) =>
      _vaults.where((vault) => vault.pubkey == pubkey).firstOrNull;

  /// The vaults [vaultId] names: one, or every vault for [allVaultsId].
  List<VaultController> select(String vaultId) =>
      vaultId == allVaultsId ? all : [?byPubkey(vaultId)];

  List<VaultItem> itemsOf(
    String vaultId, [
    ItemFilter filter = ItemFilter.all,
  ]) => [
    for (final vault in select(vaultId))
      for (final item in vault.items)
        if (filter.matches(item.cipher)) VaultItem(vault, item),
  ]..sort((a, b) => compareByName(a.item, b.item));

  VaultItem? findItem(String vaultId, String itemId) {
    for (final vault in select(vaultId)) {
      if (vault.items.where((item) => item.id == itemId).firstOrNull
          case final item?) {
        return VaultItem(vault, item);
      }
    }
    return null;
  }

  /// A new vault key, in hex.
  String newKey() => ndk.config.eventSignerFactory.generateKeyPair().$1;

  String pubkeyOf(VaultLogin login) => switch (login) {
    KeyLogin(:final privateKey) =>
      ndk.config.eventSignerFactory.derivePublicKey(privateKey),
    SignerLogin(:final pubkey) => pubkey,
  };

  /// Saves [record] on this device, and starts syncing it.
  Future<VaultController> add(VaultRecord record) async {
    await _save([for (final vault in _vaults) vault.record, record]);
    final vault = _open(record);
    notifyListeners();
    return vault;
  }

  /// Renames or recolors [vault] on this device.
  Future<void> edit(VaultController vault, {String? name, Color? color}) {
    vault.record = vault.record.copyWith(name: name, color: color);
    return _save([for (final vault in _vaults) vault.record]);
  }

  /// Removes [vault] from this device, with what it opened and its events in
  /// the cache. Its relays keep it, for it to come back once added again.
  Future<void> remove(VaultController vault) async {
    await _save([
      for (final other in _vaults)
        if (other != vault) other.record,
    ]);
    _vaults.remove(vault);
    vault.dispose();
    ndk.accounts.removeAccount(pubkey: vault.pubkey);
    notifyListeners();
    await vault.forget();
    await vault.vault.signer.dispose();
  }

  /// Whether the key of [vault]'s cache is sealed for its signer, which then
  /// opens it at each start, rather than kept on this device. Asks the signer.
  Future<void> setCacheKeySealed(VaultController vault, bool sealed) async {
    final key = vault.vault.cache!.key ?? (throw const CacheLockedException());
    vault.record = vault.record.copyWith(
      cacheKey: sealed ? await sealCacheKey(key, vault.vault.signer) : key,
      cacheKeySealed: sealed,
    );
    await _save([for (final vault in _vaults) vault.record]);
  }

  /// One write after the other, so that an older list never lands last.
  Future<void> _save(List<VaultRecord> records) {
    final key = _key ?? (throw StateError('The vaults are closed.'));
    final saved = _saving.then((_) => _storage.write(records, key));
    _saving = saved.catchError((_) {});
    return saved;
  }

  Future<void> _saving = Future.value();

  /// [onAuthUrl] gets the page where a bunker asks the user to approve.
  EventSigner _signerOf(
    VaultLogin login, {
    required void Function(String url) onAuthUrl,
  }) => switch (login) {
    KeyLogin(:final privateKey) => ndk.config.eventSignerFactory.create(
      privateKey: privateKey,
    ),
    ExtensionLogin(:final pubkey) => Nip07EventSigner(cachedPublicKey: pubkey),
    BunkerLogin(:final pubkey, :final connection) => ndk.bunkers.createSigner(
      connection,
      authCallback: onAuthUrl,
    )..cachedPublicKey = pubkey,
    SignerAppLogin(:final pubkey, :final package) => Nip55EventSigner(
      publicKey: pubkey,
      nip55Signer: Nip55Signer(package: package),
    ),
  };

  VaultController _open(VaultRecord record) {
    late final VaultController vault;
    final signer = _signerOf(
      record.login,
      onAuthUrl: (url) => vault.approvalUrl = url,
    );
    // Vault.sync authenticates as the vault, which ndk must know.
    ndk.accounts.addAccount(
      pubkey: signer.getPublicKey(),
      type: record.login is KeyLogin
          ? AccountType.privateKey
          : AccountType.externalSigner,
      signer: signer,
    );
    final store = SembastVersionStore(_database, signer.getPublicKey());
    vault = VaultController(
      record: record,
      vault: Vault(
        ndk: ndk,
        signer: signer,
        relays: relays,
        indexers: indexers,
        cache: record.cacheKeySealed
            ? VersionCache.sealed(store, record.cacheKey, signer)
            : VersionCache(store, record.cacheKey),
      ),
      engine: engine,
      signerPatience: _signerPatience,
    )..addListener(notifyListeners);
    _vaults.add(vault);
    return vault;
  }

  /// Whether [pauseSync] stopped the syncing, for an inbox to stop too.
  bool get syncPaused => _syncPaused;
  var _syncPaused = false;

  /// What an app going to the background does: nothing keeps syncing.
  Future<void> pauseSync() {
    _syncPaused = true;
    notifyListeners();
    return Future.wait([
      engine.stop(),
      for (final vault in _vaults) vault.unsubscribe(),
    ]);
  }

  void resumeSync() {
    _syncPaused = false;
    notifyListeners();
    engine.start();
    for (final vault in _vaults) {
      vault.subscribe();
      unawaited(vault.fetchRelays());
    }
  }

  @override
  void dispose() {
    for (final vault in _vaults) {
      vault.dispose();
    }
    super.dispose();
  }
}

class VaultsScope extends InheritedNotifier<Vaults> {
  const VaultsScope({super.key, required Vaults vaults, required super.child})
    : super(notifier: vaults);
}
