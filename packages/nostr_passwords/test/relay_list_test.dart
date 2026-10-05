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
        public: ['wss://relay.primal.net', 'wss://relay.nos.social'],
        private: ['wss://relay.alice.example'],
      ),
      vault,
    );

    expect(event.kind, 10002);
    expect(event.pubKey, vault.getPublicKey());
    expect(event.tags, [
      ['r', 'wss://relay.primal.net'],
      ['r', 'wss://relay.nos.social'],
    ]);
    expect(event.content, isNot(contains('relay.alice.example')));
  });

  test('the vault reads its private relays back', () async {
    final event = await signRelayList(
      const RelayList(
        public: ['wss://relay.primal.net'],
        private: ['wss://relay.alice.example'],
      ),
      vault,
    );

    final list = await readRelayList(event, vault);

    expect(list.public, ['wss://relay.primal.net']);
    expect(list.private, ['wss://relay.alice.example']);
  });

  test('without private relays, the content is empty', () async {
    final event = await signRelayList(
      const RelayList(public: ['wss://relay.primal.net']),
      vault,
    );

    expect(event.content, isEmpty);
    expect((await readRelayList(event, vault)).private, isEmpty);
  });

  test('a relay list signed by another key is rejected', () async {
    final other = signerFactory.createWithNewKeyPair();
    final event = await signRelayList(
      const RelayList(public: ['wss://relay.primal.net']),
      other,
    );

    expect(readRelayList(event, vault), throwsFormatException);
  });
}
