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
