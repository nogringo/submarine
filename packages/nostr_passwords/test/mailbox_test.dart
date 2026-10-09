import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

import 'mocks/mock_relay.dart';

void main() {
  const signerFactory = Bip340EventSignerFactory();

  test('the address is the npub of the key at the bridge', () {
    final mailbox = generateMailbox('uid.ovh', signerFactory: signerFactory);

    expect(mailbox.key, startsWith('nsec1'));
    final [npub, bridge] = mailbox.address.split('@');
    expect(bridge, 'uid.ovh');
    expect(
      Nip19.decode(npub),
      signerFactory
          .create(privateKey: Nip19.decode(mailbox.key))
          .getPublicKey(),
    );
  });

  test('each mailbox gets a key of its own', () {
    expect(
      generateMailbox('uid.ovh', signerFactory: signerFactory).key,
      isNot(generateMailbox('uid.ovh', signerFactory: signerFactory).key),
    );
  });

  group('mailboxesOf', () {
    final mailbox = generateMailbox('uid.ovh', signerFactory: signerFactory);
    final keyField = Field(
      name: 'Mailbox key',
      value: mailbox.key,
      type: FieldType.hidden,
    );

    List<({String key, String address})> mailboxesIn(Cipher cipher) =>
        mailboxesOf(cipher, signerFactory: signerFactory);

    test('finds the address as the username, a field or the email', () {
      for (final cipher in [
        Cipher(
          type: CipherType.login,
          name: 'Shop',
          login: Login(username: mailbox.address),
          fields: [keyField],
        ),
        Cipher(
          type: CipherType.login,
          name: 'Shop',
          fields: [
            keyField,
            Field(name: 'Email', value: mailbox.address),
          ],
        ),
        Cipher(
          type: CipherType.identity,
          name: 'Me',
          identity: Identity(email: mailbox.address),
          fields: [keyField],
        ),
      ]) {
        expect(mailboxesIn(cipher), [mailbox]);
      }
    });

    test('lists a mailbox once, its address in two places', () {
      final cipher = Cipher(
        type: CipherType.login,
        name: 'Shop',
        login: Login(username: mailbox.address),
        fields: [
          Field(name: 'Email', value: mailbox.address),
          keyField,
        ],
      );

      expect(mailboxesIn(cipher), [mailbox]);
    });

    test('needs both the key, hidden, and its address', () {
      final other = generateMailbox('uid.ovh', signerFactory: signerFactory);
      for (final fields in [
        // The user's own Nostr key.
        [keyField],
        [Field(name: 'Email', value: mailbox.address)],
        [
          Field(name: 'Mailbox key', value: mailbox.key),
          Field(name: 'Email', value: mailbox.address),
        ],
        [keyField, Field(name: 'Email', value: other.address)],
        [
          keyField,
          Field(name: 'Email', value: '${mailbox.address.split('@')[0]}@'),
        ],
      ]) {
        expect(
          mailboxesIn(
            Cipher(type: CipherType.login, name: 'Shop', fields: fields),
          ),
          isEmpty,
        );
      }
    });
  });

  group('publishMailboxRelays', () {
    late Ndk ndk;
    late MockRelay relay;
    late MockRelay inbox;
    late MockRelay indexer;

    setUp(() async {
      ndk = Ndk.emptyBootstrapRelaysConfig();
      relay = await _startRelay('mailbox relay');
      inbox = await _startRelay('inbox relay');
      indexer = await _startRelay('indexer');
    });

    tearDown(() => ndk.destroy());

    test('saves both lists, signed by the mailbox key', () async {
      final mailbox = generateMailbox('uid.ovh', signerFactory: signerFactory);
      final pubkey = Nip19.decode(mailbox.address.split('@')[0]);

      await publishMailboxRelays(
        ndk,
        mailbox.key,
        relays: [relay.url],
        inboxRelays: [inbox.url],
        indexers: [indexer.url],
      );

      final [relayList] = await ndk.config.cache.loadEvents(
        pubKeys: [pubkey],
        kinds: [10002],
      );
      expect(relayList.tags, [
        ['r', relay.url],
      ]);
      final [inboxList] = await ndk.config.cache.loadEvents(
        pubKeys: [pubkey],
        kinds: [10050],
      );
      expect(inboxList.tags, [
        ['relay', inbox.url],
      ]);
      for (final event in [relayList, inboxList]) {
        expect(await Bip340EventVerifier().verify(event), isTrue);
      }
    });

    test('sends the NIP-65 list to the indexers too, and no further', () async {
      final mailbox = generateMailbox('uid.ovh', signerFactory: signerFactory);

      await publishMailboxRelays(
        ndk,
        mailbox.key,
        relays: [relay.url],
        inboxRelays: [inbox.url],
        indexers: [indexer.url],
      );

      Set<int> kinds(MockRelay to) => {
        for (final event in to.receivedEvents) event.kind,
      };
      await _until(
        () =>
            kinds(relay).containsAll([10002, 10050]) &&
            kinds(indexer).contains(10002),
      );
      expect(kinds(indexer), {10002});
      expect(inbox.receivedEvents, isEmpty);
    });
  });

  group('Mailbox', () {
    late Ndk ndk;
    late String nsec;
    late EventSigner key;
    late EventSigner sender;

    setUp(() {
      ndk = Ndk.emptyBootstrapRelaysConfig();
      nsec = generateMailbox('uid.ovh', signerFactory: signerFactory).key;
      key = signerFactory.create(privateKey: Nip19.decode(nsec));
      sender = signerFactory.createWithNewKeyPair();
    });

    tearDown(() => ndk.destroy());

    Mailbox mailboxOf(
      Ndk ndk, {
      List<String> indexers = const [],
      List<String> blossomServers = const [],
    }) => Mailbox(
      ndk: ndk,
      signer: key,
      indexers: indexers,
      blossomServers: blossomServers,
    );

    Nip01Event rumor(
      int kind,
      String content, {
      int age = 0,
      List<List<String>> tags = const [],
      String? pubkey,
    }) => Nip01Event(
      pubKey: pubkey ?? sender.getPublicKey(),
      kind: kind,
      tags: [...tags],
      content: content,
      createdAt: _now - age,
    );

    test('opens the emails and private messages, the newest first', () async {
      for (final wrap in [
        await _giftWrap(rumor(1301, _email, age: 30), sender, key),
        await _giftWrap(rumor(1301, _htmlEmail, age: 20), sender, key),
        await _giftWrap(rumor(14, 'Lunch at noon?', age: 10), sender, key),
        await _giftWrap(rumor(1, 'A note'), sender, key),
      ]) {
        await ndk.config.cache.saveEvent(wrap);
      }

      final [message, html, email] = await mailboxOf(ndk).messages();

      expect(
        message,
        isA<DirectMessage>()
            .having((m) => m.text, 'text', 'Lunch at noon?')
            .having((m) => m.pubkey, 'pubkey', sender.getPublicKey()),
      );
      expect(
        html,
        isA<Email>().having(
          (m) => m.text,
          'text',
          'Confirm your address <https://example.com/confirm?t=1>',
        ),
      );
      expect(
        email,
        isA<Email>()
            .having((m) => m.from, 'from', 'noreply@example.com')
            .having((m) => m.fromName, 'fromName', 'Example')
            .having((m) => m.subject, 'subject', 'Your code')
            .having((m) => m.text, 'text', 'Your code is 123456')
            .having(
              (m) => m.date.millisecondsSinceEpoch,
              'date',
              (_now - 30) * 1000,
            ),
      );
    });

    test('leaves out a message whose seal is not its sender', () async {
      final forged = rumor(
        14,
        'I am someone else',
        pubkey: signerFactory.createWithNewKeyPair().getPublicKey(),
      );
      await ndk.config.cache.saveEvent(await _giftWrap(forged, sender, key));
      await ndk.config.cache.saveEvent(
        await _giftWrap(rumor(14, 'Hello'), sender, key),
      );

      final messages = await mailboxOf(ndk).messages();

      expect([for (final m in messages) (m as DirectMessage).text], ['Hello']);
    });

    group('on its relays', () {
      late MockRelay relay;
      late MockRelay inbox;
      late MockRelay indexer;
      late Ndk reader;

      setUp(() async {
        relay = await _startRelay('mailbox relay');
        inbox = MockRelay(name: 'inbox relay', requireAuthForRequests: true);
        await inbox.startServer();
        addTearDown(inbox.stopServer);
        indexer = await _startRelay('indexer');
        await publishMailboxRelays(
          ndk,
          nsec,
          relays: [relay.url],
          inboxRelays: [inbox.url],
          indexers: [indexer.url],
        );
        reader = Ndk.emptyBootstrapRelaysConfig();
        addTearDown(reader.destroy);
      });

      Future<void> send(Nip01Event rumor) async {
        await ndk.broadcast
            .broadcast(
              nostrEvent: await _giftWrap(rumor, sender, key),
              specificRelays: [inbox.url],
            )
            .broadcastDoneFuture;
      }

      test('finds them from the indexers, then fetches its messages', () async {
        await send(rumor(14, 'Hello'));
        final mailbox = mailboxOf(reader, indexers: [indexer.url]);

        expect(
          await mailbox.fetchRelays(),
          unorderedEquals([relay.url, inbox.url]),
        );
        await mailbox.fetch();

        final [message] = await mailbox.messages();
        expect((message as DirectMessage).text, 'Hello');
        expect(inbox.connectionsAuthenticatedAs(key.getPublicKey()), 1);
      });

      test('brings what arrives while subscribed', () async {
        final mailbox = mailboxOf(reader, indexers: [indexer.url]);
        await mailbox.fetchRelays();
        final arrived = mailbox.subscribe().first;
        await _until(
          () => inbox.connectionsAuthenticatedAs(key.getPublicKey()) == 1,
        );

        await send(rumor(14, 'Just now'));
        await arrived;

        final [message] = await mailbox.messages();
        expect((message as DirectMessage).text, 'Just now');
      });
    });

    test('downloads a large email from Blossom, checking its hash', () async {
      final aes = cryptography.AesGcm.with256bits();
      final secretKey = await aes.newSecretKey();
      final box = await aes.encrypt(utf8.encode(_email), secretKey: secretKey);
      final blob = [...box.cipherText, ...box.mac.bytes];
      final hash = sha256.convert(blob).toString();
      final wrong = await _startBlobServer([1, 2, 3]);
      final right = await _startBlobServer(blob);
      await ndk.config.cache.saveEvent(
        await _giftWrap(
          rumor(
            1301,
            '',
            tags: [
              ['x', hash],
              ['encryption-algorithm', 'aes-gcm'],
              ['decryption-key', base64Encode(await secretKey.extractBytes())],
              ['decryption-nonce', base64Encode(box.nonce)],
              ['subject', 'Your code'],
              ['mail-from', 'noreply@example.com'],
            ],
          ),
          sender,
          key,
        ),
      );
      final mailbox = mailboxOf(ndk, blossomServers: [wrong, right]);

      final [large as Email] = await mailbox.messages();
      expect(large.subject, 'Your code');
      expect(large.from, 'noreply@example.com');
      expect(large.text, isNull);

      final email = await mailbox.download(large);
      expect(email.text, 'Your code is 123456');
      expect(email.wrapId, large.wrapId);
    });

    test('tells when no Blossom server has a large email', () async {
      await ndk.config.cache.saveEvent(
        await _giftWrap(
          rumor(
            1301,
            '',
            tags: [
              [
                'x',
                sha256.convert([0]).toString(),
              ],
              ['decryption-key', base64Encode(List.filled(32, 0))],
              ['decryption-nonce', base64Encode(List.filled(12, 0))],
            ],
          ),
          sender,
          key,
        ),
      );
      final mailbox = mailboxOf(
        ndk,
        blossomServers: [
          await _startBlobServer([1, 2, 3]),
        ],
      );

      final [large as Email] = await mailbox.messages();
      expect(mailbox.download(large), throwsA(isA<EmailDownloadException>()));
    });
  });
}

final _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

const _email =
    'From: Example <noreply@example.com>\r\n'
    'To: npub1abc@uid.ovh\r\n'
    'Subject: Your code\r\n'
    'MIME-Version: 1.0\r\n'
    'Content-Type: multipart/alternative; boundary="b"\r\n'
    '\r\n'
    '--b\r\n'
    'Content-Type: text/plain; charset=utf-8\r\n'
    '\r\n'
    'Your code is 123456\r\n'
    '--b\r\n'
    'Content-Type: text/html; charset=utf-8\r\n'
    '\r\n'
    '<p>Your code is <b>123456</b></p>\r\n'
    '--b--\r\n';

const _htmlEmail =
    'From: noreply@example.com\r\n'
    'Subject: Confirm\r\n'
    'MIME-Version: 1.0\r\n'
    'Content-Type: text/html; charset=utf-8\r\n'
    '\r\n'
    '<html><head><style>p {}</style></head><body>'
    '<p><a href="https://example.com/confirm?t=1">Confirm your address</a></p>'
    '</body></html>\r\n';

/// [rumor] sealed by [sender], gift wrapped to [recipient], as NIP-59 does.
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
    eventSignerFactory: const Bip340EventSignerFactory(),
  );
}

/// A Blossom server that gives [blob] for any hash, and its URL.
Future<String> _startBlobServer(List<int> blob) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(server.close);
  server.listen((request) {
    request.response
      ..add(blob)
      ..close();
  });
  return 'http://localhost:${server.port}';
}

Future<MockRelay> _startRelay(String name) async {
  final relay = MockRelay(name: name);
  await relay.startServer();
  addTearDown(relay.stopServer);
  return relay;
}

/// Polls [condition], as the mock relay tells nothing when it changes.
Future<void> _until(bool Function() condition) async {
  while (!condition()) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
