import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:submarine_extension_core/sync.dart';
import 'package:submarine_extension_core/vaults.dart';
import 'package:test/test.dart';

import '../../../../packages/nostr_passwords/test/mocks/mock_relay.dart';
import 'memory_store.dart';

const signers = Bip340EventSignerFactory();

void main() {
  late MockRelay relay;
  late Database database;
  late Ndk ndk;
  late Vaults vaults;
  late VaultSync sync;
  late int changes;
  late String privateKey;
  late String pubkey;

  setUp(() async {
    relay = MockRelay(name: 'vault relay');
    await relay.startServer();
    database = await newDatabaseFactoryMemory().openDatabase('submarine');
    ndk = Ndk(
      NdkConfig(
        eventVerifier: Bip340EventVerifier(),
        eventSignerFactory: signers,
        cache: SembastCacheManager(database),
        bootstrapRelays: [],
      ),
    );
    vaults = Vaults(MemoryStore(), signers);
    changes = 0;
    sync = VaultSync(
      ndk: ndk,
      database: database,
      vaults: vaults,
      onChanged: () => changes++,
      relays: [relay.url],
      indexers: const [],
    );
    (privateKey, pubkey) = signers.generateKeyPair();
  });

  tearDown(() async {
    await sync.stop();
    await ndk.destroy();
    await relay.stopServer();
  });

  /// Another device of the vault, which publishes to the relay at once.
  Future<void> publish(String name) async {
    final other = Ndk.emptyBootstrapRelaysConfig();
    addTearDown(other.destroy);
    final device = Vault(
      ndk: other,
      signer: signers.create(privateKey: privateKey),
      relays: [relay.url],
      indexers: const [],
    );
    await device.createItem(Cipher(type: CipherType.secureNote, name: name));
    expect(await device.push(), isEmpty);
  }

  Future<int> opened() async =>
      (await SembastVersionStore(database, pubkey).read()).length;

  Future<void> addVault() =>
      vaults.add(key: privateKey, name: 'Home', color: 0xFF1F5FA8);

  test('syncs the vaults once started, and opens their items', () async {
    await publish('Wifi');
    await addVault();

    await sync.start();

    await _until(() async => await opened() == 1);
    await _until(() async => sync.states().single['lastSync'] != null);
    expect(sync.states().single, containsPair('pubkey', pubkey));
    expect(changes, greaterThan(0));
  });

  test('brings what another device publishes while started', () async {
    await addVault();
    await sync.start();
    await _until(() async => sync.states().single['lastSync'] != null);

    await publish('Wifi');

    await _until(() async => await opened() == 1);
  });

  test('syncs a vault opened once started', () async {
    await publish('Wifi');
    await sync.start();
    expect(sync.states(), isEmpty);

    await addVault();
    await sync.update();

    await _until(() async => await opened() == 1);
  });

  test('brings nothing more once stopped', () async {
    await addVault();
    await sync.start();
    await _until(() async => sync.states().single['lastSync'] != null);

    await sync.stop();
    await publish('Wifi');
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(await opened(), 0);
  });

  test('syncs nothing before it starts', () async {
    await addVault();

    await sync.update();

    expect(sync.states(), isEmpty);
  });
}

/// Polls [condition], as the relay tells nothing when it changes.
Future<void> _until(Future<bool> Function() condition) async {
  while (!await condition()) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
