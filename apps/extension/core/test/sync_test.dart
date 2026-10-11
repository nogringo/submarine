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

  /// Another device of the vault of [key], which publishes to the relay at
  /// once. Returns the id of the item.
  Future<String> publish(String name, {Cipher? cipher, String? key}) async {
    final other = Ndk.emptyBootstrapRelaysConfig();
    addTearDown(other.destroy);
    final device = Vault(
      ndk: other,
      signer: signers.create(privateKey: key ?? privateKey),
      relays: [relay.url],
      indexers: const [],
    );
    final version = await device.createItem(
      cipher ?? Cipher(type: CipherType.secureNote, name: name),
    );
    expect(await device.push(), isEmpty);
    return version.id;
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

  test('reads the items opened, trash left out, by name', () async {
    await publish('wifi');
    await publish(
      'GitHub',
      cipher: Cipher(
        type: CipherType.login,
        name: 'GitHub',
        login: Login(username: 'alice'),
      ),
    );
    await publish(
      'Old bank',
      cipher: Cipher(type: CipherType.secureNote, name: 'Old bank')
        ..deletedDate = DateTime.utc(2026, 10, 1),
    );
    await addVault();
    await sync.start();
    await _until(() async => await opened() == 3);

    final items = await sync.items();

    expect(items, [
      allOf(
        containsPair('vault', pubkey),
        containsPair('type', 1),
        containsPair('name', 'GitHub'),
        containsPair('subtitle', 'alice'),
      ),
      allOf(containsPair('type', 2), containsPair('name', 'wifi')),
    ]);
  });

  test('reads the items of one vault or of all', () async {
    final (otherKey, otherPubkey) = signers.generateKeyPair();
    await publish('Wifi');
    await publish('Alarm code', key: otherKey);
    await addVault();
    await vaults.add(key: otherKey, name: 'Work', color: 0xFF1F5FA8);
    await sync.start();
    await _until(() async => (await sync.items()).length == 2);

    expect(
      [for (final item in await sync.items(pubkey: otherPubkey)) item['name']],
      ['Alarm code'],
    );
    expect(
      [for (final item in await sync.items()) item['vault']],
      [otherPubkey, pubkey],
    );
  });

  test('reads the items the search finds, as the app does', () async {
    await publish(
      'GitHub',
      cipher: Cipher(
        type: CipherType.login,
        name: 'GitHub',
        login: Login(username: 'alice', uris: [LoginUri('https://github.com')]),
      ),
    );
    await publish('Société générale');
    await addVault();
    await sync.start();
    await _until(() async => await opened() == 2);

    Future<List<Object?>> names(String query) async => [
      for (final item in await sync.items(query: query)) item['name'],
    ];
    expect(await names('societe'), ['Société générale']);
    expect(await names('alice github.com'), ['GitHub']);
    expect(await names('  '), ['GitHub', 'Société générale']);
    expect(await names('bank'), isEmpty);
  });

  test('reads an item in full, none once in the trash', () async {
    await publish(
      'GitHub',
      cipher: Cipher(
        type: CipherType.login,
        name: 'GitHub',
        login: Login(username: 'alice', password: 'hunter2'),
      ),
    );
    final trashed = await publish(
      'Old bank',
      cipher: Cipher(type: CipherType.secureNote, name: 'Old bank')
        ..deletedDate = DateTime.utc(2026, 10, 1),
    );
    await addVault();
    await sync.start();
    await _until(() async => await opened() == 2);
    final [github] = await sync.items();

    final item = await sync.item(pubkey: pubkey, id: github['id'] as String);

    expect(item, containsPair('vault', pubkey));
    expect(
      (item!['cipher'] as Map)['login'],
      allOf(
        containsPair('username', 'alice'),
        containsPair('password', 'hunter2'),
      ),
    );
    expect(await sync.item(pubkey: pubkey, id: trashed), isNull);
    expect(await sync.item(pubkey: pubkey, id: 'unknown'), isNull);
  });

  test('reads what was opened before it starts', () async {
    await publish('Wifi');
    await addVault();
    await sync.start();
    await _until(() async => await opened() == 1);
    await sync.stop();

    final again = VaultSync(
      ndk: ndk,
      database: database,
      vaults: vaults,
      onChanged: () {},
      relays: [relay.url],
      indexers: const [],
    );

    expect([for (final item in await again.items()) item['name']], ['Wifi']);
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
