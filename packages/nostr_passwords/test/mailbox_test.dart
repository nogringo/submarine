import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

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
}
