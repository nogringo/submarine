import 'package:flutter/widgets.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import '../items/item_filter.dart';
import 'vault_controller.dart';
import 'vault_storage.dart';

/// The same relays as the CLI.
const defaultRelays = [
  'wss://relay.nmail.li',
  'wss://nos.lol',
  'wss://nostr.mom',
  'wss://relay.primal.net',
  'wss://relay.nos.social',
  'wss://offchain.pub',
  'wss://relay.coinos.io',
  'wss://nostr-pub.wellorder.net',
  'wss://relay.ditto.pub',
];

const vaultColors = [
  Color(0xFF2F6FD0),
  Color(0xFFB95A22),
  Color(0xFF2A7F61),
  Color(0xFF8A4FBF),
  Color(0xFFB8336A),
  Color(0xFF5B6B7A),
];

/// Stands for every vault where a vault's public key is expected.
const allVaultsId = 'all';

class VaultItem {
  const VaultItem(this.vault, this.item);

  final VaultController vault;
  final Item item;
}

/// The vaults of this device. A vault is added, never removed.
class Vaults extends ChangeNotifier {
  Vaults._({
    required this.ndk,
    required this.engine,
    required this.relays,
    required this._storage,
  });

  /// Opens the vaults saved on this device, and starts syncing them.
  static Future<Vaults> load({
    required Ndk ndk,
    required SyncEngine engine,
    required VaultStorage storage,
    List<String> relays = defaultRelays,
  }) async {
    final vaults = Vaults._(
      ndk: ndk,
      engine: engine,
      relays: relays,
      storage: storage,
    );
    for (final record in await storage.read()) {
      vaults._open(record);
    }
    engine.start();
    return vaults;
  }

  static Vaults of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VaultsScope>()!.notifier!;

  final Ndk ndk;
  final SyncEngine engine;
  final List<String> relays;
  final VaultStorage _storage;
  final _vaults = <VaultController>[];

  List<VaultController> get all => List.unmodifiable(_vaults);
  bool get isEmpty => _vaults.isEmpty;

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

  String publicKeyOf(String privateKey) =>
      ndk.config.eventSignerFactory.derivePublicKey(privateKey);

  /// Saves [record] on this device, and starts syncing it.
  Future<VaultController> add(VaultRecord record) async {
    await _storage.write([for (final vault in _vaults) vault.record, record]);
    final vault = _open(record);
    notifyListeners();
    return vault;
  }

  VaultController _open(VaultRecord record) {
    final signer = ndk.config.eventSignerFactory.create(
      privateKey: record.privateKey,
    );
    // Vault.sync authenticates as the vault, which ndk must know.
    ndk.accounts.addAccount(
      pubkey: signer.getPublicKey(),
      type: AccountType.privateKey,
      signer: signer,
    );
    final vault = VaultController(
      record: record,
      vault: Vault(ndk: ndk, signer: signer, relays: relays),
      engine: engine,
    )..addListener(notifyListeners);
    _vaults.add(vault);
    return vault;
  }

  /// What an app going to the background does: nothing keeps syncing.
  Future<void> pauseSync() => engine.stop();

  void resumeSync() => engine.start();

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
