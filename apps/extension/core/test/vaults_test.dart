import 'dart:convert';

import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:submarine_extension_core/core.dart';
import 'package:submarine_extension_core/vaults.dart';
import 'package:test/test.dart';

class MemoryStore implements KeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

const privateKey =
    '3501454135014541350145413501453fefb02227e449e57cf4d3a3ce05378683';
const signers = Bip340EventSignerFactory();
final pubkey = signers.derivePublicKey(privateKey);

void main() {
  late MemoryStore store;
  late Vaults vaults;

  setUp(() {
    store = MemoryStore();
    vaults = Vaults(store, signers);
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

  test('keeps the vaults encrypted with the key of the device', () async {
    await vaults.add(key: privateKey, name: 'Home', color: 1);
    final saved = store.values['vaults']!;
    expect(saved, isNot(contains(privateKey)));
    final deviceKey = SymmetricCryptoKey(
      base64.decode(store.values['deviceKey']!),
    );
    expect(await deviceKey.decryptString(saved), contains(privateKey));
    expect(await Vaults(store, signers).list(), hasLength(1));
  });
}
