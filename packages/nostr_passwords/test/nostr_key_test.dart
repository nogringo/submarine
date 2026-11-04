import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

void main() {
  const signerFactory = Bip340EventSignerFactory();

  test('the npub is the public key of the nsec', () {
    final key = generateNostrKey(signerFactory: signerFactory);

    expect(key.nsec, startsWith('nsec1'));
    expect(
      Nip19.encodePubKey(signerFactory.derivePublicKey(Nip19.decode(key.nsec))),
      key.npub,
    );
  });

  test('each key is new', () {
    expect(
      generateNostrKey(signerFactory: signerFactory).nsec,
      isNot(generateNostrKey(signerFactory: signerFactory).nsec),
    );
  });
}
