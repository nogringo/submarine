import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

void main() {
  const signerFactory = Bip340EventSignerFactory();
  late EventSigner vault;

  setUp(() => vault = signerFactory.createWithNewKeyPair());

  test('public relays go in the tags, private ones in the content', () async {
    final event = await signRelayList(
      const RelayList(
        public: {
          'wss://relay.primal.net': ReadWriteMarker.readWrite,
          'wss://relay.nos.social': ReadWriteMarker.readOnly,
          'wss://relay.coinos.io': ReadWriteMarker.writeOnly,
        },
        private: {'wss://relay.alice.example': ReadWriteMarker.readWrite},
      ),
      vault,
    );

    expect(event.kind, 10002);
    expect(event.pubKey, vault.getPublicKey());
    expect(event.tags, [
      ['r', 'wss://relay.primal.net'],
      ['r', 'wss://relay.nos.social', 'read'],
      ['r', 'wss://relay.coinos.io', 'write'],
    ]);
    expect(event.content, isNot(contains('relay.alice.example')));
  });

  test('the vault reads its relays back, markers included', () async {
    const relays = RelayList(
      public: {
        'wss://relay.primal.net': ReadWriteMarker.readWrite,
        'wss://relay.nos.social': ReadWriteMarker.readOnly,
      },
      private: {
        'wss://relay.alice.example': ReadWriteMarker.writeOnly,
        'wss://relay.bob.example': ReadWriteMarker.readWrite,
      },
    );

    final list = await readRelayList(await signRelayList(relays, vault), vault);

    expect(list.public, relays.public);
    expect(list.private, relays.private);
  });

  test('without private relays, the content is empty', () async {
    final event = await signRelayList(
      const RelayList(
        public: {'wss://relay.primal.net': ReadWriteMarker.readWrite},
      ),
      vault,
    );

    expect(event.content, isEmpty);
    expect((await readRelayList(event, vault)).private, isEmpty);
  });

  test('a relay list signed by another key is rejected', () async {
    final other = signerFactory.createWithNewKeyPair();
    final event = await signRelayList(
      const RelayList(
        public: {'wss://relay.primal.net': ReadWriteMarker.readWrite},
      ),
      other,
    );

    expect(readRelayList(event, vault), throwsFormatException);
  });

  group('changing a list', () {
    const list = RelayList(
      public: {
        'wss://relay.primal.net': ReadWriteMarker.readWrite,
        'wss://relay.nos.social/': ReadWriteMarker.readOnly,
      },
      private: {'wss://relay.alice.example': ReadWriteMarker.writeOnly},
    );

    test('urls lists the public relays, then the private ones', () {
      expect(list.urls, [
        'wss://relay.primal.net',
        'wss://relay.nos.social/',
        'wss://relay.alice.example',
      ]);
    });

    test('contains compares normalized URLs', () {
      expect(list.contains('WSS://Relay.Nos.Social'), isTrue);
      expect(list.contains('wss://relay.example.com'), isFalse);
    });

    test('withRelay adds a public or a private relay, normalized', () {
      final added = list
          .withRelay(' WSS://Relay.Example.com/ ')
          .withRelay(
            'wss://relay.bob.example',
            marker: ReadWriteMarker.readOnly,
            private: true,
          );

      expect(added.public, {
        ...list.public,
        'wss://relay.example.com': ReadWriteMarker.readWrite,
      });
      expect(added.private, {
        ...list.private,
        'wss://relay.bob.example': ReadWriteMarker.readOnly,
      });
    });

    test('withRelay replaces the settings of a relay already listed', () {
      final changed = list.withRelay(
        'wss://relay.nos.social',
        marker: ReadWriteMarker.writeOnly,
        private: true,
      );

      expect(changed.public, {
        'wss://relay.primal.net': ReadWriteMarker.readWrite,
      });
      expect(changed.private, {
        'wss://relay.alice.example': ReadWriteMarker.writeOnly,
        'wss://relay.nos.social': ReadWriteMarker.writeOnly,
      });
    });

    test('withRelay refuses what parseRelayUrl refuses', () {
      expect(
        () => list.withRelay('https://relay.example.com'),
        throwsArgumentError,
      );
      expect(() => list.withRelay('wss://typo'), throwsArgumentError);
    });

    test('without removes a public or a private relay', () {
      final removed = list
          .without('wss://relay.nos.social')
          .without('wss://relay.alice.example');

      expect(removed.public, {
        'wss://relay.primal.net': ReadWriteMarker.readWrite,
      });
      expect(removed.private, isEmpty);
      expect(removed.without('wss://relay.primal.net').isEmpty, isTrue);
    });
  });

  group('parseRelayUrl', () {
    test('normalizes a relay URL', () {
      expect(
        parseRelayUrl(' WSS://Relay.Example.com/ '),
        'wss://relay.example.com',
      );
      expect(parseRelayUrl('ws://127.0.0.1:7777'), 'ws://127.0.0.1:7777');
      expect(parseRelayUrl('ws://localhost:7777'), 'ws://localhost:7777');
    });

    test('takes an address without a scheme for wss://', () {
      expect(parseRelayUrl('relay.example.com'), 'wss://relay.example.com');
    });

    test('refuses what is not a websocket URL', () {
      expect(parseRelayUrl('https://relay.example.com'), isNull);
      expect(parseRelayUrl(''), isNull);
    });

    test('refuses a host without a dot', () {
      expect(parseRelayUrl('typo'), isNull);
      expect(parseRelayUrl('wss://typo'), isNull);
    });
  });
}
