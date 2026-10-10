import 'dart:convert';
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
  // Keeps what the signer opened from one start to the next, encrypted under
  // a key the app keeps as safely as the vault key.
  final store = JsonFileVersionStore(File('versions.json'));
  final cacheKey = newCacheKey();
  final vault = Vault(
    ndk: ndk,
    signer: signer,
    relays: defaultVaultRelays,
    cache: VersionCache(store, cacheKey),
  );
  // Or the key sealed for the signer alone, which opens it at each start:
  // until it does, the vault shows nothing, even what it opened before.
  final sealed = VersionCache.sealed(
    store,
    await sealCacheKey(cacheKey, signer),
    signer,
  );
  print('The signer opened the cache key: ${await sealed.unlock()}');

  // What the app keeps on the device, locked with a password as Bitwarden
  // protects the user key of an account with its master password.
  final deviceKey = SymmetricCryptoKey.generate();
  final secrets = await deviceKey.encryptString(
    jsonEncode({'vaultKey': privateKey, 'cacheKey': cacheKey}),
  );
  final protectedKey = jsonEncode(
    await PasswordProtectedKey.protect(deviceKey, '<lock password>'),
  );
  final unlocked = await PasswordProtectedKey.fromJson(
    jsonDecode(protectedKey) as Map<String, dynamic>,
  ).open('<lock password>');
  print('Unlocked: ${await unlocked?.decryptString(secrets) != null}');

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

  // Its Blossom servers (BUD-03), the private ones encrypted to the vault. The
  // list lives on the vault's relays and comes with the sync. Until it has one,
  // the vault uses vault.blossomServers, defaultVaultBlossomServers here.
  final servers = await vault.currentServerList();
  await vault.setServerList(
    servers
        .without('https://nostr.download')
        // As a user types it: https:// when it has no scheme.
        .withServer('files.alice.example', private: true),
  );
  print('Private servers: ${(await vault.serverList())?.private.join(', ')}');

  // Reads the whole vault from every relay, then gives the cache and each
  // relay what it lacks, such as what a relay dropped over time.
  final unsynced = await vault.reconcile();
  unsynced.forEach((relay, reason) => print('$relay left out: $reason'));

  // What other devices publish from now on, the moment they do.
  final live = vault.subscribe().listen((_) async {
    print('Now ${(await vault.items()).length} item(s)');
  });

  // What this device opened before shows without waiting for the signer, the
  // rest once it answers. items() does both.
  print('${(await vault.openedItems()).length} item(s) opened before');
  if (await vault.open()) print('The signer opened new versions');

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
  // The bridge a user picked, as they typed it, or the default one.
  final bridge = parseMailBridge(' @Mail.Example.com ') ?? defaultMailBridge;
  // A key for this address alone, kept in a hidden field next to it.
  final mailbox = generateMailbox(
    bridge,
    signerFactory: ndk.config.eventSignerFactory,
  );
  print('Sign up with ${mailbox.address}');
  final shop = Cipher(
    type: CipherType.login,
    name: 'Shop',
    login: Login(username: mailbox.address),
    fields: [
      Field(name: 'Mailbox key', value: mailbox.key, type: FieldType.hidden),
    ],
  );
  await vault.createItem(shop);
  // Once the item holding it is saved, the mailbox tells the bridge where its
  // emails go: a NIP-65 list, on the indexers too, then a kind:10050 list, and
  // a kind:10063 list for those too large for a gift wrap.
  for (final (:key, :address) in mailboxesOf(
    shop,
    signerFactory: ndk.config.eventSignerFactory,
  )) {
    await publishMailboxLists(
      ndk,
      key,
      relays: defaultMailboxRelays,
      inboxRelays: defaultMailboxInboxRelays,
      blossomServers: defaultMailboxBlossomServers,
    );
    print('$address receives emails');
  }
  // Its emails and private messages, opened with the key the item holds.
  final inbox = Mailbox(
    ndk: ndk,
    signer: ndk.config.eventSignerFactory.create(
      privateKey: Nip19.decode(mailbox.key),
    ),
  );
  await inbox.fetchRelays();
  final arrivals = inbox.subscribe().listen((_) {});
  await inbox.fetch();
  for (final message in await inbox.messages()) {
    switch (message) {
      case Email(text: null):
        // Too large for a gift wrap, it waits on Blossom.
        final email = await inbox.download(message);
        print('${email.subject}: ${email.text}');
      case Email(:final subject, :final text):
        print('$subject: $text');
      case DirectMessage(:final text):
        print('Message: $text');
    }
  }
  await arrivals.cancel();

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

  // A file is encrypted under a key of its own, which the item holds. The
  // encrypted file is for the vault's Blossom servers, which address it by
  // attachment.sha256.
  final (attachment, encryptedFile) = await encryptAttachment(
    'recovery-codes.txt',
    utf8.encode('3f7a-91c2 8be0-44d1'),
  );
  boulanger.cipher.attachments.add(attachment);
  final file = await decryptAttachment(attachment, encryptedFile);
  print('${attachment.fileName}: ${utf8.decode(file!)}');

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
  engine.release(handle);
  // Removes the vault from this device only: its relays keep it.
  await vault.forget(engine);
  await engine.dispose();
  await ndk.destroy();
}

/// The entries of a VersionCache in a JSON file. An app would rather keep them
/// in its database.
class JsonFileVersionStore implements VersionStore {
  JsonFileVersionStore(this.file);

  final File file;

  @override
  Future<Map<String, String>> read() async => file.existsSync()
      ? (jsonDecode(await file.readAsString()) as Map).cast<String, String>()
      : {};

  @override
  Future<void> write(Map<String, String> entries) async =>
      _save({...await read(), ...entries});

  @override
  Future<void> remove(Iterable<String> wrapIds) async =>
      _save({...await read()}..removeWhere((id, _) => wrapIds.contains(id)));

  Future<void> _save(Map<String, String> entries) =>
      file.writeAsString(jsonEncode(entries));
}
