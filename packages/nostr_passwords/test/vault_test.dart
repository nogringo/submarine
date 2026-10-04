import 'dart:convert';

import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast_memory.dart' show newDatabaseFactoryMemory;
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';
import 'package:test/test.dart';

import 'mocks/mock_relay.dart';

void main() {
  late MockRelay relay;
  late Ndk ndk;
  late EventSigner signer;
  late Vault vault;

  final boulanger = Cipher(
    type: CipherType.login,
    name: 'Boulanger',
    login: Login(username: 'alice@example.com', password: 'hunter2'),
  );

  setUp(() async {
    relay = MockRelay(name: 'vault relay');
    await relay.startServer();
    ndk = Ndk.emptyBootstrapRelaysConfig();
    signer = const Bip340EventSignerFactory().createWithNewKeyPair();
    vault = Vault(ndk: ndk, signer: signer, relays: [relay.url]);
  });

  tearDown(() async {
    await ndk.destroy();
    await relay.stopServer();
  });

  test('createItem saves the item without waiting for the relays', () async {
    final offline = Vault(
      ndk: ndk,
      signer: signer,
      relays: ['ws://127.0.0.1:1'],
    );

    await offline.createItem(boulanger).timeout(const Duration(seconds: 2));

    final [item] = await offline.items();
    expect(item.cipher.name, 'Boulanger');
    final [unsent] = await offline.unsent();
    expect(unsent.event?.kind, 1059);
  });

  test('push sends what createItem saved as a gift wrap', () async {
    final item = await vault.createItem(boulanger);

    expect(await vault.push(), isEmpty);

    final wrap = relay.receivedEvents.last;
    expect(wrap.kind, 1059);
    expect((await unwrapEnvelope(wrap, signer)).toJson(), item.toJson());
    expect(await vault.unsent(), isEmpty);
  });

  test('push returns what no relay accepted', () async {
    relay.rejectFirstEventPublishes = 1000;
    await vault.createItem(boulanger);

    final [left] = await vault.push();

    expect(left.event?.kind, 1059);
    expect(left.relayTargets.single.lastError, contains('rate-limited'));
  });

  test('push authenticates as the vault when the relay asks', () async {
    relay.requireAuthForEvents = true;
    await vault.createItem(boulanger);

    await vault.push();

    expect(
      relay.eventsAuthenticatedAs(signer.getPublicKey()),
      contains(relay.receivedEvents.last.id),
    );
  });

  test('items lists what this device created', () async {
    await vault.createItem(boulanger);

    final [item] = await vault.items();
    expect(item.cipher.login?.password, 'hunter2');
  });

  group('updateItem', () {
    /// The data updateItem publishes once [edit] changed [original].
    Future<Cipher> saveEdited(
      Cipher original,
      void Function(Cipher cipher) edit,
    ) async {
      await vault.createItem(original);
      final [item] = await vault.items();
      edit(item.cipher);
      return Cipher.fromJson((await vault.updateItem(item, item.cipher)).data);
    }

    test('publishes a version that replaces the current one', () async {
      final created = await vault.createItem(boulanger);
      final [item] = await vault.items();

      final updated = await vault.updateItem(
        item,
        item.cipher..name = 'Boulanger.com',
      );

      expect(updated.id, created.id);
      expect(updated.parents, [created.rev]);
      final [current] = await vault.items();
      expect(current.heads.single.rev, updated.rev);
      expect(current.cipher.name, 'Boulanger.com');
    });

    test('replaces every head of a conflict', () async {
      await vault.createItem(boulanger);
      final [item] = await vault.items();
      final first = await vault.updateItem(
        item,
        Cipher.fromJson(item.current.data)..notes = 'first',
      );
      final second = await vault.updateItem(
        item,
        Cipher.fromJson(item.current.data)..notes = 'second',
      );
      final [conflicted] = await vault.items();
      expect(conflicted.hasConflict, isTrue);

      final merged = await vault.updateItem(conflicted, conflicted.cipher);

      expect(merged.parents, unorderedEquals([first.rev, second.rev]));
      final [resolved] = await vault.items();
      expect(resolved.hasConflict, isFalse);
    });

    test('records the replaced password', () async {
      final before = DateTime.now().toUtc();

      final saved = await saveEdited(
        boulanger,
        (cipher) => cipher.login!.password = 'hunter3',
      );

      final [entry] = saved.passwordHistory;
      expect(entry.password, 'hunter2');
      expect(entry.lastUsedDate!.isBefore(before), isFalse);
      expect(saved.revisionDate, entry.lastUsedDate);
    });

    test('leaves the history alone when no password changes', () async {
      final saved = await saveEdited(
        boulanger,
        (cipher) => cipher.notes = 'Loyalty card 1234',
      );

      expect(saved.passwordHistory, isEmpty);
    });

    test('records the hidden fields that change', () async {
      final saved = await saveEdited(
        Cipher(
          type: CipherType.login,
          name: 'Bank',
          fields: [
            Field(name: 'PIN', value: '1234', type: FieldType.hidden),
            Field(name: 'Code', value: '42', type: FieldType.hidden),
            Field(name: 'Branch', value: 'Paris'),
          ],
        ),
        (cipher) => cipher.fields = [
          Field(name: 'Code', value: '42', type: FieldType.hidden),
        ],
      );

      expect(
        [for (final entry in saved.passwordHistory) entry.password],
        ['PIN: 1234'],
      );
    });

    test('keeps the 5 latest entries, whatever history it is given', () async {
      final saved = await saveEdited(
        Cipher(
          type: CipherType.login,
          name: 'Boulanger',
          login: Login(password: 'hunter2'),
          passwordHistory: [
            for (var i = 5; i > 0; i--) PasswordHistory(password: 'old$i'),
          ],
        ),
        (cipher) => cipher
          ..login!.password = 'hunter3'
          ..passwordHistory = [],
      );

      expect(
        [for (final entry in saved.passwordHistory) entry.password],
        ['hunter2', 'old5', 'old4', 'old3', 'old2'],
      );
    });
  });

  test('trashItem and restoreItem set and clear deletedDate', () async {
    await vault.createItem(boulanger);
    final [item] = await vault.items();

    final trashed = await vault.trashItem(item);

    expect(trashed.parents, [item.current.rev]);
    final [inTrash] = await vault.items();
    expect(inTrash.cipher.isDeleted, isTrue);
    expect(inTrash.cipher.deletedDate, inTrash.cipher.revisionDate);

    await vault.restoreItem(inTrash);

    final [restored] = await vault.items();
    expect(restored.cipher.isDeleted, isFalse);
    expect(restored.cipher.name, 'Boulanger');
  });

  group('deleteItem', () {
    int seconds() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

    test('asks the relays to delete each gift wrap of the item', () async {
      await vault.createItem(boulanger);
      final [item] = await vault.items();
      await vault.updateItem(item, item.cipher..notes = 'Loyalty card 1234');
      final boulangerWraps = [
        for (final wrap in await ndk.config.cache.loadEvents(kinds: [1059]))
          wrap.id,
      ];
      await vault.createItem(
        Cipher(type: CipherType.secureNote, name: 'Wi-Fi'),
      );

      final before = seconds();
      await vault.deleteItem(item);
      final after = seconds();
      await vault.push();

      final requests = {
        for (final event in relay.receivedEvents)
          if (event.kind == 5) event.id: event,
      }.values;
      expect([
        for (final request in requests) ...request.getTags('e'),
      ], unorderedEquals(boulangerWraps));
      for (final request in requests) {
        expect(request.pubKey, signer.getPublicKey());
        expect(request.getTags('k'), ['1059']);
        expect(request.content, isEmpty);
        expect(
          request.createdAt,
          inInclusiveRange(before - 2 * 24 * 60 * 60, after),
        );
        expect(await Bip340EventVerifier().verify(request), isTrue);
      }
      final [left] = await vault.items();
      expect(left.cipher.name, 'Wi-Fi');
      expect(await ndk.config.cache.loadEvents(ids: boulangerWraps), isEmpty);
    });

    test('leaves out of unsent the gift wraps it drops', () async {
      final offline = Vault(
        ndk: ndk,
        signer: signer,
        relays: ['ws://127.0.0.1:1'],
      );
      await offline.createItem(boulanger);
      final [item] = await offline.items();

      await offline.deleteItem(item);

      expect(
        [for (final delivery in await offline.unsent()) delivery.event?.kind],
        [5],
      );
    });

    test('a version published afterwards brings the item back', () async {
      await vault.createItem(boulanger);
      final [item] = await vault.items();
      await vault.deleteItem(item);
      expect(await vault.items(), isEmpty);

      final late = await vault.updateItem(
        item,
        Cipher.fromJson(item.current.data)..notes = 'Edited offline',
      );

      final [back] = await vault.items();
      expect(back.current.rev, late.rev);
    });

    test('items ignore deletion requests the vault did not sign', () async {
      await vault.createItem(boulanger);
      final [wrap] = await ndk.config.cache.loadEvents(kinds: [1059]);
      final attacker = const Bip340EventSignerFactory().createWithNewKeyPair();
      await ndk.config.cache.saveEvent(
        await attacker.sign(
          Nip01Event(
            pubKey: attacker.getPublicKey(),
            kind: 5,
            tags: [
              ['e', wrap.id],
              ['k', '1059'],
            ],
            content: '',
          ),
        ),
      );

      final [item] = await vault.items();
      expect(item.cipher.name, 'Boulanger');
    });
  });

  group('on another device', () {
    late Ndk otherNdk;
    late SyncEngine engine;
    late Vault otherVault;

    setUp(() async {
      otherNdk = Ndk.emptyBootstrapRelaysConfig();
      otherNdk.accounts.addAccount(
        pubkey: signer.getPublicKey(),
        type: AccountType.privateKey,
        signer: signer,
      );
      engine = SyncEngine(
        otherNdk,
        store: SembastSyncStore(
          await newDatabaseFactoryMemory().openDatabase('sync.db'),
        ),
      );
      otherVault = Vault(ndk: otherNdk, signer: signer, relays: [relay.url]);
    });

    tearDown(() async {
      await engine.dispose();
      await otherNdk.destroy();
    });

    /// What this device gets once the first one pushed its changes.
    Future<List<Item>> syncedItems() async {
      await vault.push();
      final handle = otherVault.sync(engine);
      engine.start();
      await engine
          .watchStatus(handle)
          .firstWhere((status) => status.phase == SyncRequestPhase.synced);
      return otherVault.items();
    }

    test('items are synced from the relays', () async {
      final created = await vault.createItem(boulanger);

      final [item] = await syncedItems();
      expect(item.id, created.id);
      expect(item.cipher.name, 'Boulanger');
    });

    test('items drop what the vault deleted for good', () async {
      await vault.createItem(boulanger);
      await syncedItems();
      final [item] = await vault.items();
      await vault.deleteItem(item);

      // This engine deems the vault synced for 5 more minutes.
      await engine.dispose();
      engine = SyncEngine(
        otherNdk,
        store: SembastSyncStore(
          await newDatabaseFactoryMemory().openDatabase('sync.db'),
        ),
      );

      expect(await syncedItems(), isEmpty);
      expect(
        await otherNdk.config.cache.loadEvents(
          kinds: [GiftWrap.kGiftWrapEventkind],
        ),
        isEmpty,
      );
    });

    test('lastSync is null before the first sync', () async {
      expect(await otherVault.lastSync(engine), isNull);
    });

    test('lastSync is when the last sync started', () async {
      // Coverage is stored to the second.
      final before = DateTime.now().toUtc().subtract(
        const Duration(seconds: 1),
      );
      await syncedItems();
      final after = DateTime.now().toUtc();

      final lastSync = await otherVault.lastSync(engine);
      expect(lastSync!.isBefore(before), isFalse);
      expect(lastSync.isAfter(after), isFalse);
    });

    test('lastSync ignores a sync no relay answered', () async {
      final offline = Vault(
        ndk: otherNdk,
        signer: signer,
        relays: ['ws://127.0.0.1:1'],
      );
      final handle = offline.sync(engine);
      engine.start();
      await engine
          .watchStatus(handle)
          .firstWhere((status) => status.phase == SyncRequestPhase.failed);

      expect(await offline.lastSync(engine), isNull);
    });

    test('items are synced from relays that require AUTH', () async {
      relay.requireAuthForRequests = true;
      final created = await vault.createItem(boulanger);

      final [item] = await syncedItems();
      expect(item.id, created.id);
    });

    test('wraps the vault did not sign are ignored', () async {
      await vault.createItem(boulanger);
      final attacker = const Bip340EventSignerFactory().createWithNewKeyPair();
      final forgedVersion = await attacker.sign(
        Nip01Event(
          pubKey: attacker.getPublicKey(),
          kind: versionEventKind,
          tags: [
            ['-'],
          ],
          content: jsonEncode({
            'v': 1,
            'id': 'forged',
            'type': 'item',
            'rev': 'forged',
            'parents': [],
            'modified_at': 0,
            'data': {'type': 1, 'name': 'Forged'},
          }),
        ),
      );
      final undecryptable = await attacker.sign(
        Nip01Event(
          pubKey: attacker.getPublicKey(),
          kind: GiftWrap.kGiftWrapEventkind,
          tags: [
            ['p', signer.getPublicKey()],
          ],
          content: 'not encrypted',
        ),
      );
      for (final wrap in [
        await GiftWrap.wrapEvent(
          recipientPublicKey: signer.getPublicKey(),
          sealEvent: forgedVersion,
          eventSignerFactory: const Bip340EventSignerFactory(),
        ),
        undecryptable,
      ]) {
        await ndk.broadcast
            .broadcast(nostrEvent: wrap, specificRelays: [relay.url])
            .broadcastDoneFuture;
      }

      final [item] = await syncedItems();
      expect(item.cipher.name, 'Boulanger');
      expect(
        await otherNdk.config.cache.loadEvents(
          kinds: [GiftWrap.kGiftWrapEventkind],
        ),
        hasLength(3),
      );
    });
  });
}
