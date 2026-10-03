import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast_io.dart' show databaseFactoryIo;
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

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

  final saved = await vault.createItem(
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
  print('Saved ${saved.data['name']} as item ${saved.id}');

  final engine = SyncEngine(
    ndk,
    db: await databaseFactoryIo.openDatabase('sync.db'),
  );
  final handle = vault.sync(engine);
  engine.start();
  await engine
      .watchStatus(handle)
      .firstWhere(
        (status) =>
            status.phase == SyncRequestPhase.synced ||
            status.phase == SyncRequestPhase.failed,
      );

  for (final item in await vault.items()) {
    print('${item.cipher.name}: ${item.cipher.login?.username}');
  }

  await engine.dispose();
  await ndk.destroy();
}
