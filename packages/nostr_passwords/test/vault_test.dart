import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
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
}
