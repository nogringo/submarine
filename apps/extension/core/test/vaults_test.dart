import 'dart:convert';

import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:submarine_extension_core/core.dart';
import 'package:submarine_extension_core/device_key.dart';
import 'package:submarine_extension_core/vaults.dart';
import 'package:test/test.dart';

import 'memory_store.dart';

const privateKey =
    '3501454135014541350145413501453fefb02227e449e57cf4d3a3ce05378683';
const signers = Bip340EventSignerFactory();
final pubkey = signers.derivePublicKey(privateKey);

void main() {
  late MemoryStore store;
  late Vaults vaults;

  /// The vaults as the next start of the background reads them.
  Vaults reopened() => Vaults(store, signers, DeviceKey(store, MemoryStore()));

  setUp(() {
    store = MemoryStore();
    vaults = reopened();
  });

  Matcher throwsCode(String code, [String? message]) => throwsA(
    isA<CoreException>()
        .having((error) => error.code, 'code', code)
        .having((error) => error.message, 'message', message),
  );

  test('has no vault at first', () async {
    expect(await vaults.list(), isEmpty);
  });

  test('opens a vault from its nsec, and lists it without its key', () async {
    final nsec = Nip19.encodePrivateKey(privateKey);
    final vault = await vaults.add(key: nsec, name: ' Home ', color: 1);
    expect(vault, {'pubkey': pubkey, 'name': 'Home', 'color': 1});
    expect(await vaults.list(), [vault]);
  });

  test('opens a vault from its key in hex', () async {
    await vaults.add(key: privateKey, name: 'Home', color: 1);
    expect((await vaults.records()).single.privateKey, privateKey);
  });

  test('opens a vault from its ncryptsec and the password', () async {
    final ncryptsec = await encryptVaultKey(privateKey, 'a long password');
    await expectLater(
      vaults.add(key: ncryptsec, password: 'wrong', name: 'Home', color: 1),
      throwsCode('vaultKeyPasswordWrong'),
    );
    await vaults.add(
      key: ncryptsec,
      password: 'a long password',
      name: 'Home',
      color: 1,
    );
    expect((await vaults.records()).single.privateKey, privateKey);
  });

  test('refuses what is not a vault key, an npub included', () async {
    for (final key in ['', 'hello', Nip19.encodePubKey(pubkey)]) {
      await expectLater(
        vaults.add(key: key, name: 'Home', color: 1),
        throwsCode('vaultKeyInvalid'),
      );
    }
  });

  test('refuses a vault without a name', () async {
    await expectLater(
      vaults.add(key: privateKey, name: '  ', color: 1),
      throwsCode('vaultNameRequired'),
    );
  });

  test('refuses a vault already open, by its name', () async {
    await vaults.add(key: privateKey, name: 'Home', color: 1);
    await expectLater(
      vaults.add(
        key: Nip19.encodePrivateKey(privateKey),
        name: 'Work',
        color: 2,
      ),
      throwsCode('vaultAlreadyOpen', 'Home'),
    );
  });

  test('renames a vault and changes its color, its key kept', () async {
    await vaults.add(key: privateKey, name: 'Home', color: 1);
    final cacheKey = (await vaults.records()).single.cacheKey;

    expect(await vaults.edit(pubkey, name: ' Family '), {
      'pubkey': pubkey,
      'name': 'Family',
      'color': 1,
    });
    expect(await vaults.edit(pubkey, color: 2), containsPair('color', 2));

    final record = (await reopened().records()).single;
    expect(record.name, 'Family');
    expect(record.color, 2);
    expect(record.privateKey, privateKey);
    expect(record.cacheKey, cacheKey);
  });

  test('refuses an empty name, or a vault not open', () async {
    await vaults.add(key: privateKey, name: 'Home', color: 1);
    await expectLater(
      vaults.edit(pubkey, name: ' '),
      throwsCode('vaultNameRequired'),
    );
    await expectLater(
      vaults.edit(signers.derivePublicKey('${'1' * 63}2'), name: 'Work'),
      throwsCode('vaultNotFound'),
    );
    expect((await vaults.records()).single.name, 'Home');
  });

  test('keeps every edit made at once', () async {
    await vaults.add(key: privateKey, name: 'Home', color: 1);

    await Future.wait([
      vaults.edit(pubkey, name: 'Family'),
      vaults.edit(pubkey, color: 2),
    ]);

    final record = (await vaults.records()).single;
    expect((record.name, record.color), ('Family', 2));
  });

  test('removes a vault, the others kept', () async {
    const otherKey =
        '7f7ff03d123792d6ac594bfa67bf6d0c0ab55b6b1fdb6249303fe861f1ccba9a';
    await vaults.add(key: privateKey, name: 'Home', color: 1);
    await vaults.add(key: otherKey, name: 'Work', color: 2);

    expect((await vaults.remove(pubkey)).privateKey, privateKey);

    expect([for (final vault in await vaults.list()) vault['name']], ['Work']);
    await expectLater(vaults.remove(pubkey), throwsCode('vaultNotFound'));
  });

  test('keeps the vaults encrypted with the key of the device', () async {
    await vaults.add(key: privateKey, name: 'Home', color: 1);
    final saved = store.values['vaults']!;
    expect(saved, isNot(contains(privateKey)));
    final deviceKey = SymmetricCryptoKey(
      base64.decode(store.values['deviceKey']!),
    );
    expect(await deviceKey.decryptString(saved), contains(privateKey));
    expect(await reopened().list(), hasLength(1));
  });
}
