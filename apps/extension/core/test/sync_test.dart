import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip09/deletion.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:submarine_extension_core/core.dart';
import 'package:submarine_extension_core/device_key.dart';
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
    final store = MemoryStore();
    vaults = Vaults(store, signers, DeviceKey(store, MemoryStore()));
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

  test('syncs a vault again at once when asked', () async {
    await addVault();
    await sync.start();
    await _until(() async => sync.states().single['lastSync'] != null);
    final before = sync.states().single['lastSync'];
    // A pass covers whole seconds.
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    await sync.syncNow(pubkey: pubkey);

    await _until(() async => sync.states().single['lastSync'] != before);
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
        containsPair('copies', null),
      ),
      allOf(containsPair('type', 2), containsPair('name', 'wifi')),
    ]);
  });

  test('tells what the row of an item copies, as in the app', () async {
    await publish(
      'GitHub',
      cipher: Cipher(
        type: CipherType.login,
        name: 'GitHub',
        login: Login(username: 'alice', password: 'hunter2'),
      ),
    );
    await publish(
      'Visa',
      cipher: Cipher(
        type: CipherType.card,
        name: 'Visa',
        card: PaymentCard(number: '4111111111111111'),
      ),
    );
    await addVault();
    await sync.start();
    await _until(() async => await opened() == 2);

    expect(
      [for (final item in await sync.items()) item['copies']],
      ['password', 'number'],
    );
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

  test('reads the logins for a page, as Bitwarden matches them', () async {
    Cipher login(String name, String uri) => Cipher(
      type: CipherType.login,
      name: name,
      login: Login(uris: [LoginUri(uri)]),
    );
    await publish('GitHub', cipher: login('GitHub', 'https://github.com'));
    await publish('Gist', cipher: login('Gist', 'gist.github.com'));
    await publish('GitLab', cipher: login('GitLab', 'https://gitlab.com'));
    await publish('github.com');
    await addVault();
    await sync.start();
    await _until(() async => await opened() == 4);

    Future<List<Object?>> names(String url, [String query = '']) async => [
      for (final item in await sync.items(url: url, query: query)) item['name'],
    ];
    expect(await names('https://github.com/login'), ['Gist', 'GitHub']);
    expect(await names('https://github.com/login', 'gist'), ['Gist']);
    expect(await names('https://example.com'), isEmpty);
  });

  test('reads the favorites, the items of a type, or the trash', () async {
    await publish('wifi');
    await publish(
      'GitHub',
      cipher: Cipher(type: CipherType.login, name: 'GitHub')..favorite = true,
    );
    await publish(
      'Visa',
      cipher: Cipher(type: CipherType.card, name: 'Visa', card: PaymentCard()),
    );
    await publish(
      'Old bank',
      cipher: Cipher(type: CipherType.login, name: 'Old bank')
        ..favorite = true
        ..deletedDate = DateTime.utc(2026, 10, 1),
    );
    await addVault();
    await sync.start();
    await _until(() async => await opened() == 4);

    Future<List<Object?>> names(Object filter, [String query = '']) async => [
      for (final item in await sync.items(filter: filter, query: query))
        item['name'],
    ];
    expect(await names('all'), ['GitHub', 'Visa', 'wifi']);
    expect(await names('favorites'), ['GitHub']);
    expect(await names(CipherType.login.value), ['GitHub']);
    expect(await names(CipherType.secureNote.value), ['wifi']);
    expect(await names('trash'), ['Old bank']);
    expect(await names('trash', 'git'), isEmpty);
    expect(() => sync.items(filter: 'archive'), throwsA(isA<CoreException>()));
  });

  test('tells the types of the items, trash left out', () async {
    await publish('wifi');
    await publish('Router');
    await publish(
      'Visa',
      cipher: Cipher(type: CipherType.card, name: 'Visa', card: PaymentCard()),
    );
    await publish(
      'Old bank',
      cipher: Cipher(type: CipherType.login, name: 'Old bank')
        ..deletedDate = DateTime.utc(2026, 10, 1),
    );
    await addVault();
    await sync.start();
    await _until(() async => await opened() == 4);

    expect(
      await sync.itemTypes(),
      unorderedEquals([CipherType.secureNote.value, CipherType.card.value]),
    );
    expect(await sync.itemTypes(pubkey: 'unknown'), isEmpty);
  });

  test('reads an item in full, in the trash or not, none once gone', () async {
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
    expect(
      (await sync.item(pubkey: pubkey, id: trashed))!['cipher'],
      containsPair('deletedDate', isNotNull),
    );
    expect(await sync.item(pubkey: pubkey, id: 'unknown'), isNull);
  });

  group('changes an item', () {
    late String id;

    setUp(() async {
      id = await publish('Wifi');
      await addVault();
      await sync.start();
      await _until(() async => await opened() == 1);
    });

    Future<Map<String, dynamic>> cipher() async =>
        (await sync.item(pubkey: pubkey, id: id))!['cipher']
            as Map<String, dynamic>;

    /// The events the vault sent to its relay since [before] of them.
    Future<List<Nip01Event>> sentSince(int before) async {
      await _until(() async => relay.receivedEvents.length > before);
      return relay.receivedEvents.sublist(before);
    }

    test('adds it to the favorites, takes it out, and tells', () async {
      final before = changes;

      await sync.setFavorite(pubkey: pubkey, id: id, favorite: true);

      expect(await cipher(), containsPair('favorite', true));
      expect(
        [for (final item in await sync.items(filter: 'favorites')) item['id']],
        [id],
      );
      expect(changes, greaterThan(before));

      await sync.setFavorite(pubkey: pubkey, id: id, favorite: false);

      expect(await cipher(), containsPair('favorite', false));
    });

    test('moves it to the trash and restores it', () async {
      await sync.trashItem(pubkey: pubkey, id: id);

      expect(await cipher(), containsPair('deletedDate', isNotNull));
      expect(await sync.items(), isEmpty);
      expect(await sync.itemTypes(), isEmpty);

      await sync.restoreItem(pubkey: pubkey, id: id);

      expect(await cipher(), containsPair('deletedDate', null));
      expect(await sync.items(filter: 'trash'), isEmpty);
    });

    test('sends the change to the vault\'s relays', () async {
      final before = relay.receivedEvents.length;

      await sync.trashItem(pubkey: pubkey, id: id);

      expect(
        [for (final event in await sentSince(before)) event.kind],
        [GiftWrap.kGiftWrapEventkind],
      );
    });

    test('deletes it for good, and asks the relays to delete it', () async {
      await sync.trashItem(pubkey: pubkey, id: id);

      await sync.deleteItem(pubkey: pubkey, id: id);

      expect(await sync.item(pubkey: pubkey, id: id), isNull);
      expect(await sync.items(filter: 'trash'), isEmpty);
      // One request for each version, the first one and the trashed one.
      await _until(
        () async =>
            relay.receivedEvents
                .where((event) => event.kind == Deletion.kKind)
                .length ==
            2,
      );
    });

    test('saves two changes asked at once one after the other', () async {
      await Future.wait([
        sync.setFavorite(pubkey: pubkey, id: id, favorite: true),
        sync.trashItem(pubkey: pubkey, id: id),
      ]);

      expect(
        await cipher(),
        allOf(
          containsPair('favorite', true),
          containsPair('deletedDate', isNotNull),
        ),
      );
    });

    test('fails for an item or a vault gone', () async {
      expect(
        () => sync.trashItem(pubkey: pubkey, id: 'unknown'),
        throwsA(
          isA<CoreException>().having(
            (error) => error.code,
            'code',
            'itemNotFound',
          ),
        ),
      );
      expect(
        () => sync.trashItem(pubkey: 'unknown', id: id),
        throwsA(
          isA<CoreException>().having(
            (error) => error.code,
            'code',
            'vaultNotFound',
          ),
        ),
      );
    });
  });

  test('shows the newest version of an item edited on two devices', () async {
    final other = Ndk.emptyBootstrapRelaysConfig();
    addTearDown(other.destroy);
    final device = Vault(
      ndk: other,
      signer: signers.create(privateKey: privateKey),
      relays: [relay.url],
      indexers: const [],
    );
    final first = Item([
      await device.createItem(
        Cipher(type: CipherType.secureNote, name: 'Wifi'),
      ),
    ]);
    // Both name the first version, as two devices that missed each other.
    await device.updateItem(
      first,
      Cipher(type: CipherType.secureNote, name: 'Older'),
    );
    // Versions are dated to the millisecond, the same one would be a draw.
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await device.updateItem(
      first,
      Cipher(type: CipherType.secureNote, name: 'Newer'),
    );
    expect(await device.push(), isEmpty);
    await addVault();
    await sync.start();
    await _until(() async => await opened() == 3);

    final [summary] = await sync.items();
    final item = await sync.item(pubkey: pubkey, id: summary['id'] as String);

    expect(summary['name'], 'Newer');
    expect((item!['cipher'] as Map)['name'], 'Newer');
  });

  test('forgets a vault removed, which its relays keep', () async {
    await publish('Wifi');
    await addVault();
    await sync.start();
    await _until(() async => await opened() == 1);

    await sync.forget(await vaults.remove(pubkey));

    expect(sync.states(), isEmpty);
    expect(await sync.items(), isEmpty);
    expect(await opened(), 0);
    final wraps = await ndk.config.cache.loadEvents(
      kinds: [GiftWrap.kGiftWrapEventkind],
      tags: {
        'p': [pubkey],
      },
    );
    expect(wraps, isEmpty);

    await addVault();
    await sync.update();
    await _until(() async => await opened() == 1);
  });

  test('lets go of the vaults once closed', () async {
    await publish('Wifi');
    await addVault();
    await sync.start();
    await _until(() async => await opened() == 1);

    await sync.close();

    expect(sync.states(), isEmpty);
    expect(ndk.accounts.hasAccount(pubkey), isFalse);
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
