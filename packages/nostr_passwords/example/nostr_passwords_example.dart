import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

Future<void> main() async {
  final ndk = Ndk.defaultConfig();
  final vault = Vault(
    ndk: ndk,
    signer: Bip340EventSigner(
      privateKey: '<vault private key, hex>',
      publicKey: '<vault public key, hex>',
    ),
    relays: ['wss://relay.damus.io', 'wss://nos.lol'],
  );

  final item = await vault.createItem(
    Cipher(
      type: CipherType.login,
      name: 'Boulanger',
      login: Login(
        uris: [LoginUri('https://www.boulanger.com')],
        username: 'alice@example.com',
        password: 'correct horse battery staple',
      ),
    ),
  );
  print('Saved ${item.data['name']} as item ${item.id}');

  await ndk.destroy();
}
