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

  test('createItem publishes the item as a gift wrap', () async {
    final item = await vault.createItem(boulanger);

    final [wrap] = relay.receivedEvents;
    expect(wrap.kind, 1059);
    expect((await unwrapEnvelope(wrap, signer)).toJson(), item.toJson());
  });

  test('createItem throws when no relay accepts the item', () async {
    relay.rejectFirstEventPublishes = 1;

    await expectLater(
      vault.createItem(boulanger),
      throwsA(isA<PublishException>()),
    );
  });

  test('items lists what this device created', () async {
    await vault.createItem(boulanger);

    final [item] = await vault.items();
    expect(item.cipher.login?.password, 'hunter2');
  });

  group('on another device', () {
    late Ndk otherNdk;
    late SyncEngine engine;
    late Vault otherVault;

    setUp(() async {
      otherNdk = Ndk.emptyBootstrapRelaysConfig();
      engine = SyncEngine(
        otherNdk,
        db: await newDatabaseFactoryMemory().openDatabase('sync.db'),
      );
      otherVault = Vault(ndk: otherNdk, signer: signer, relays: [relay.url]);
    });

    tearDown(() async {
      await engine.dispose();
      await otherNdk.destroy();
    });

    Future<List<Item>> syncedItems() async {
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
