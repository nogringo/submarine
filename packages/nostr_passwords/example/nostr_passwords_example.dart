import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast_io.dart' show databaseFactoryIo;
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

Future<void> main() async {
  final ndk = Ndk.defaultConfig();
  // A vault key, as an nsec or in hex.
  final signer = const Bip340EventSignerFactory().create(
    privateKey: parseVaultKey('<vault key, nsec1...>')!,
  );
  // vault.sync authenticates as the vault, which ndk must know.
  ndk.accounts.addAccount(
    pubkey: signer.getPublicKey(),
    type: AccountType.privateKey,
    signer: signer,
  );
  final vault = Vault(
    ndk: ndk,
    signer: signer,
    relays: ['wss://relay.primal.net'],
  );

  final saved = await vault.createItem(
    Cipher(
      type: CipherType.login,
      name: 'Boulanger',
      login: Login(
        uris: [LoginUri('https://www.boulanger.com')],
        username: 'alice@example.com',
        password: 'correct horse battery staple',
        totp: 'otpauth://totp/Boulanger:alice?secret=JBSWY3DPEHPK3PXP',
      ),
    ),
  );
  print('Saved ${saved.data['name']} as item ${saved.id}');

  // Saved in the ndk cache, which ndk sends in the background: push sends it
  // now, and returns what no relay accepted.
  final unsent = await vault.push();
  print('${unsent.length} change(s) left to send');

  final engine = SyncEngine(
    ndk,
    store: SembastSyncStore(await databaseFactoryIo.openDatabase('sync.db')),
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
  print('Synced up to ${await vault.lastSync(engine)}');

  // What other devices publish from now on, the moment they do.
  final live = vault.subscribe().listen((_) async {
    print('Now ${(await vault.items()).length} item(s)');
  });

  final items = await vault.items();
  for (final item in items) {
    print('${item.cipher.name}: ${item.cipher.subtitle}');
  }
  // Ignores case and accents, and looks in usernames, hostnames and notes.
  final found = searchItems(items, 'boulanger alice');
  print('Found ${found.length} item(s) for "boulanger alice"');

  // The replaced password goes to the item's password history.
  final boulanger = found.first;
  final totp = generateTotp(boulanger.cipher.login!.totp!);
  print('TOTP code ${totp.code}, renewed every ${totp.period.inSeconds} s');

  final updated = await vault.updateItem(
    boulanger,
    boulanger.cipher..login!.password = 'Tr0ub4dor&3',
  );

  // A published version replaces every head of the item.
  final trashed = await vault.trashItem(Item([updated]));
  await vault.restoreItem(Item([trashed]));

  // Asks the relays to delete every version of the item, for good.
  await vault.deleteItem(boulanger);
  await vault.push();

  await live.cancel();
  await engine.dispose();
  await ndk.destroy();
}
