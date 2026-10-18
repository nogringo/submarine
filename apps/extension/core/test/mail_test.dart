import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast_memory.dart' show newDatabaseFactoryMemory;
import 'package:submarine_extension_core/core.dart';
import 'package:submarine_extension_core/device_key.dart';
import 'package:submarine_extension_core/mail_settings.dart';
import 'package:submarine_extension_core/sync.dart';
import 'package:submarine_extension_core/vaults.dart';
import 'package:test/test.dart';

import '../../../../packages/nostr_passwords/test/mocks/mock_relay.dart';
import 'memory_store.dart';

const signers = Bip340EventSignerFactory();

void main() {
  group('MailSettings', () {
    late MemoryStore store;
    late MailSettings mail;

    setUp(() {
      store = MemoryStore();
      mail = MailSettings(store);
    });

    test('gives the defaults until changed', () async {
      expect(await mail.bridge(), defaultMailBridge);
      expect(await mail.urls(MailList.inbox), defaultMailboxInboxRelays);
      expect(await mail.toJson(), {
        'bridge': defaultMailBridge,
        'defaultBridge': defaultMailBridge,
        'address': {
          'urls': defaultMailboxRelays,
          'defaults': defaultMailboxRelays,
        },
        'inbox': {
          'urls': defaultMailboxInboxRelays,
          'defaults': defaultMailboxInboxRelays,
        },
        'servers': {
          'urls': defaultMailboxBlossomServers,
          'defaults': defaultMailboxBlossomServers,
        },
      });
    });

    test('saves a bridge as typed, under the app\'s name', () async {
      await mail.setBridge(' @Mail.Example.com ');

      expect(await mail.bridge(), 'mail.example.com');
      expect(store.values, {'mailBridge': 'mail.example.com'});
    });

    test('refuses a bridge that is no domain', () async {
      await expectLater(
        mail.setBridge('localhost'),
        throwsA(
          isA<CoreException>().having((e) => e.code, 'code', 'invalidBridge'),
        ),
      );
    });

    test('keeps a default unset, to follow a new default', () async {
      await mail.setBridge('mail.example.com');
      await mail.setUrls(MailList.servers, ['https://blossom.example.com']);

      await mail.setBridge(defaultMailBridge);
      await mail.setUrls(MailList.servers, defaultMailboxBlossomServers);

      expect(store.values, isEmpty);
    });
  });

  group('the mailboxes of the items', () {
    late MockRelay vaultRelay;
    late MockRelay addressRelay;
    late MockRelay inboxRelay;
    late Ndk ndk;
    late VaultSync sync;
    late int inboxChanges;
    late String pubkey;
    late ({String key, String address}) mailbox;
    late EventSigner mailboxSigner;

    setUp(() async {
      vaultRelay = await _startRelay('vault relay');
      addressRelay = await _startRelay('address relay');
      inboxRelay = await _startRelay('inbox relay');
      ndk = Ndk(
        NdkConfig(
          eventVerifier: Bip340EventVerifier(),
          eventSignerFactory: signers,
          cache: SembastCacheManager(
            await newDatabaseFactoryMemory().openDatabase('submarine'),
          ),
          bootstrapRelays: [],
          // The lists of a mailbox wait for a retry if sent before the
          // relay is connected.
          pendingDeliveryRetryInterval: const Duration(seconds: 2),
        ),
      );
      final store = MemoryStore();
      final vaults = Vaults(store, signers, DeviceKey(store, MemoryStore()));
      final mail = MailSettings(MemoryStore());
      await mail.setUrls(MailList.address, [addressRelay.url]);
      await mail.setUrls(MailList.inbox, [inboxRelay.url]);
      await mail.setUrls(MailList.servers, []);
      inboxChanges = 0;
      sync = VaultSync(
        ndk: ndk,
        database: await newDatabaseFactoryMemory().openDatabase('versions'),
        vaults: vaults,
        mail: mail,
        onChanged: () {},
        onInboxChanged: () => inboxChanges++,
        relays: [vaultRelay.url],
        indexers: const [],
      );
      final (privateKey, publicKey) = signers.generateKeyPair();
      pubkey = publicKey;
      await vaults.add(key: privateKey, name: 'Home', color: 0xFF1F5FA8);
      await sync.start();
      mailbox = generateMailbox('uid.ovh', signerFactory: signers);
      mailboxSigner = signers.create(privateKey: Nip19.decode(mailbox.key));
    });

    tearDown(() async {
      await sync.stop();
      await ndk.destroy();
    });

    Map<String, dynamic> withMailbox(String name) => Cipher(
      type: CipherType.login,
      name: name,
      login: Login(username: mailbox.address),
      fields: [
        Field(name: 'Mailbox key', value: mailbox.key, type: FieldType.hidden),
      ],
    ).toJson();

    /// The lists the mailbox sent to its address relay so far.
    List<Nip01Event> listsSent() => [
      for (final event in addressRelay.receivedEvents)
        if (event.pubKey == mailboxSigner.getPublicKey()) event,
    ];

    test('tells the mailboxes of an item', () async {
      final id = await sync.createItem(
        pubkey: pubkey,
        cipher: withMailbox('Shop'),
      );

      final item = await sync.item(pubkey: pubkey, id: id);

      expect(item!['mailboxes'], [
        {'key': mailbox.key, 'address': mailbox.address},
      ]);
    });

    test('publishes the lists of a new mailbox once the item is saved, and '
        'not again', () async {
      final id = await sync.createItem(
        pubkey: pubkey,
        cipher: withMailbox('Shop'),
      );
      await _until(() async => listsSent().length == 3);
      expect([
        for (final event in listsSent()) event.kind,
      ], unorderedEquals([10002, 10050, 10063]));

      final read = (await sync.item(pubkey: pubkey, id: id))!;
      await sync.updateItem(
        pubkey: pubkey,
        base: read['base'] as List<Object?>,
        cipher: {...read['cipher'] as Map<String, dynamic>, 'name': 'Store'},
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(listsSent(), hasLength(3));
    });

    group('once its lists are published', () {
      late Ndk sender;
      late EventSigner senderSigner;

      setUp(() async {
        await sync.createItem(pubkey: pubkey, cipher: withMailbox('Shop'));
        await _until(() async => listsSent().length == 3);
        sender = Ndk.emptyBootstrapRelaysConfig();
        addTearDown(sender.destroy);
        senderSigner = signers.createWithNewKeyPair();
      });

      Future<Nip01Event> send(int kind, String content) async {
        final wrap = await _giftWrap(
          Nip01Event(
            pubKey: senderSigner.getPublicKey(),
            kind: kind,
            tags: const [],
            content: content,
          ),
          senderSigner,
          mailboxSigner,
        );
        await sender.broadcast
            .broadcast(nostrEvent: wrap, specificRelays: [inboxRelay.url])
            .broadcastDoneFuture;
        return wrap;
      }

      test('reads its messages once synced, then what arrives', () async {
        final wrap = await send(14, 'Hello');

        await sync.inboxes.sync(mailbox.key);

        expect(await sync.inboxes.messages(mailbox.key), [
          {
            'wrapId': wrap.id,
            'pubkey': senderSigner.getPublicKey(),
            'date': isA<int>(),
            'kind': 'privateMessage',
            'text': 'Hello',
          },
        ]);
        expect(inboxChanges, greaterThan(0));

        await send(1301, _email);

        await _until(
          () async => (await sync.inboxes.messages(mailbox.key)).length == 2,
        );
        final email = (await sync.inboxes.messages(mailbox.key))
            .singleWhere((message) => message['kind'] == 'email');
        expect(email, {
          'wrapId': isA<String>(),
          'pubkey': senderSigner.getPublicKey(),
          'date': isA<int>(),
          'kind': 'email',
          'from': 'noreply@example.com',
          'fromName': 'Example',
          'subject': 'Your code',
        });
      });

      test('opens an email in full', () async {
        final wrap = await send(1301, _email);
        await sync.inboxes.sync(mailbox.key);

        final email = await sync.inboxes.message(mailbox.key, wrap.id);

        expect(email, containsPair('text', 'Your code is 123456'));
        expect(email, containsPair('mime', _email));
      });

      test('deletes a message, on its relays too', () async {
        final wrap = await send(14, 'Hello');
        await sync.inboxes.sync(mailbox.key);

        await sync.inboxes.delete(mailbox.key, wrap.id);

        expect(await sync.inboxes.messages(mailbox.key), isEmpty);
        await _until(
          () async => inboxRelay.matchingEvents(Filter(ids: [wrap.id])).isEmpty,
        );
      });

      test('brings nothing more once closed', () async {
        await sync.inboxes.sync(mailbox.key);
        await sync.inboxes.close(mailbox.key);

        await send(14, 'Too late');
        await Future<void>.delayed(const Duration(milliseconds: 300));

        expect(await sync.inboxes.messages(mailbox.key), isEmpty);
      });
    });

    test('fails for a message or a key unknown', () async {
      await expectLater(
        sync.inboxes.message(mailbox.key, 'unknown'),
        throwsA(
          isA<CoreException>().having((e) => e.code, 'code', 'messageNotFound'),
        ),
      );
      await expectLater(
        sync.inboxes.messages('not a key'),
        throwsA(
          isA<CoreException>().having(
            (e) => e.code,
            'code',
            'invalidMailboxKey',
          ),
        ),
      );
    });
  });
}

const _email =
    'From: Example <noreply@example.com>\r\n'
    'Subject: Your code\r\n'
    'Content-Type: text/plain; charset=utf-8\r\n'
    '\r\n'
    'Your code is 123456\r\n';

Future<Nip01Event> _giftWrap(
  Nip01Event rumor,
  EventSigner sender,
  EventSigner recipient,
) async {
  final seal = await sender.sign(
    Nip01Event(
      pubKey: sender.getPublicKey(),
      kind: GiftWrap.kSealEventKind,
      tags: const [],
      content: (await sender.encryptNip44(
        plaintext: Nip01EventModel.fromEntity(rumor).toJsonString(),
        recipientPubKey: recipient.getPublicKey(),
      ))!,
    ),
  );
  return GiftWrap.wrapEvent(
    recipientPublicKey: recipient.getPublicKey(),
    sealEvent: seal,
    eventSignerFactory: signers,
  );
}

Future<MockRelay> _startRelay(String name) async {
  final relay = MockRelay(name: name);
  await relay.startServer();
  addTearDown(relay.stopServer);
  return relay;
}

/// Polls [condition], as the relay tells nothing when it changes.
Future<void> _until(Future<bool> Function() condition) async {
  while (!await condition()) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
