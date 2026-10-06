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
}
