import 'dart:io';

import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast_io.dart' show databaseFactoryIo;
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

Future<void> main() async {
  final ndk = Ndk.defaultConfig();
  // A vault key, as an nsec or in hex, or encrypted with a password (NIP-49).
  const vaultKey = '<vault key, nsec1... or ncryptsec1...>';
  final privateKey = isEncryptedVaultKey(vaultKey)
      ? await decryptVaultKey(vaultKey, '<password>')
      : parseVaultKey(vaultKey);
  // Any EventSigner works, a NIP-46 bunker or a NIP-07 extension too. A
  // bunker is asked for vaultSignerPermissions when it connects.
  const bunkerClient = Nip46ClientMetadata(
    name: 'My app',
    perms: vaultSignerPermissions,
  );
  print('A bunker would be asked for ${bunkerClient.perms!.join(', ')}');
  final signer = const Bip340EventSignerFactory().create(
    privateKey: privateKey!,
  );
  // vault.sync authenticates as the vault, which ndk must know.
  ndk.accounts.addAccount(
    pubkey: signer.getPublicKey(),
    type: AccountType.privateKey,
    signer: signer,
  );
  final vault = Vault(ndk: ndk, signer: signer, relays: defaultRelays);

  // Its relay list (NIP-65), the private relays encrypted to the vault. It
  // goes to vault.relays, to the relays it lists and to the indexers. From now
  // on the vault lives on the relays it lists, which get a copy of the vault.
  // It reads and writes on all of them: the markers are for other clients.
  await vault.setRelayList(
    const RelayList(
      public: {
        'wss://relay.primal.net': ReadWriteMarker.readWrite,
        'wss://relay.nos.social': ReadWriteMarker.readOnly,
      },
      private: {'wss://relay.alice.example': ReadWriteMarker.readWrite},
    ),
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
  final handle = await vault.sync(engine);
  engine.start();
  await engine
      .watchStatus(handle)
      .firstWhere(
        (status) =>
            status.phase == SyncRequestPhase.synced ||
            status.phase == SyncRequestPhase.failed,
      );
  print('Synced up to ${await vault.lastSync(engine)}');
  // Not part of the sync: fetched from where setRelayList publishes it.
  final relayList = await vault.fetchRelayList();
  print('Private relays: ${relayList?.private.keys.join(', ')}');

  // Changes the newest list, or the vault's relays while it has none.
  final current = await vault.currentRelayList();
  // As a user types it: wss:// when it has no scheme, null when invalid.
  final typed = parseRelayUrl('relay.bob.example')!;
  await vault.setRelayList(
    current.without('wss://relay.nos.social').withRelay(typed, private: true),
  );

  // Reads the whole vault from every relay, then gives the cache and each
  // relay what it lacks, such as what a relay dropped over time.
  final unsynced = await vault.reconcile();
  unsynced.forEach((relay, reason) => print('$relay left out: $reason'));

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

  final boulanger = found.first;
  final totp = generateTotp(boulanger.cipher.login!.totp!);
  print('TOTP code ${totp.code}, renewed every ${totp.period.inSeconds} s');

  // Bitwarden's generator, options and defaults included.
  final password = generatePassword(
    const PasswordGeneratorOptions(length: 20, special: true),
  );
  print('Or a passphrase: ${generatePassphrase()}');
  print('A username: ${generateUsername()}');

  // Made-up details for the sites that ask for them.
  print(
    'Sign up as ${generateFirstName()} ${generateLastName()}, '
    'born ${generateBirthDate()}',
  );

  // Bitwarden's JSON export, both ways, password protected or not.
  final bitwardenExport = File('bitwarden_export.json');
  if (bitwardenExport.existsSync()) {
    final source = await bitwardenExport.readAsString();
    List<Cipher> ciphers;
    try {
      ciphers = parseBitwardenExport(source);
    } on PasswordProtectedExportException {
      ciphers = parseBitwardenExport(
        await decryptBitwardenExport(source, '<file password>'),
      );
    }
    for (final cipher in ciphers) {
      await vault.createItem(cipher);
    }
  }
  final export = writeBitwardenExport(await vault.items());
  await File('vault_export.json')
      .writeAsString(await encryptBitwardenExport(export, '<file password>'));

  // The replaced password goes to the item's password history.
  final updated = await vault.updateItem(
    boulanger,
    boulanger.cipher..login!.password = password,
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
