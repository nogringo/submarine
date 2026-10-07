import 'dart:convert';

import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

/// Within Bitwarden's bounds, as cheap as they allow.
const cheapKdf = KdfConfig.argon2id(iterations: 2, memory: 16, parallelism: 1);

void main() {
  group('SymmetricCryptoKey', () {
    test('is 64 random bytes', () {
      final a = SymmetricCryptoKey.generate();
      final b = SymmetricCryptoKey.generate();

      expect(a.bytes, hasLength(64));
      expect(a.bytes, isNot(b.bytes));
    });

    test('refuses a key that is not 64 bytes', () {
      expect(() => SymmetricCryptoKey(List.filled(32, 1)), throwsArgumentError);
    });

    test('decrypts what it encrypted, as an EncString of type 2', () async {
      final key = SymmetricCryptoKey.generate();
      final encrypted = await key.encryptString('Mot de passe : été');

      expect(encrypted, matches(RegExp(r'^2\.[^|]+\|[^|]+\|[^|]+$')));
      expect(
        await SymmetricCryptoKey(key.bytes).decryptString(encrypted),
        'Mot de passe : été',
      );
    });

    test('opens nothing another key encrypted', () async {
      final encrypted = await SymmetricCryptoKey.generate().encryptString('a');

      expect(
        await SymmetricCryptoKey.generate().decryptString(encrypted),
        isNull,
      );
    });

    test('opens nothing whose MAC does not match', () async {
      final key = SymmetricCryptoKey.generate();
      final [iv, cipherText, _] = (await key.encryptString('a')).split('|');
      final forged = [
        iv,
        cipherText,
        base64.encode(List.filled(32, 0)),
      ].join('|');

      expect(await key.decryptString(forged), isNull);
    });

    test('refuses what is not an EncString', () async {
      await expectLater(
        SymmetricCryptoKey.generate().decryptString('hunter2'),
        throwsFormatException,
      );
    });
  });

  group('PasswordProtectedKey', () {
    test('opens with its password only', () async {
      final key = SymmetricCryptoKey.generate();
      final protected = await PasswordProtectedKey.protect(
        key,
        'hunter2',
        kdf: cheapKdf,
      );

      expect((await protected.open('hunter2'))!.bytes, key.bytes);
      expect(await protected.open('hunter3'), isNull);
      expect(await protected.open(''), isNull);
    });

    test('protects with Argon2id, Bitwarden defaults', () async {
      final key = SymmetricCryptoKey.generate();
      final json = (await PasswordProtectedKey.protect(
        key,
        'hunter2',
      )).toJson();

      expect(base64.decode(json['salt'] as String), hasLength(16));
      expect(json, containsPair('kdfType', 1));
      expect(json, containsPair('kdfIterations', 6));
      expect(json, containsPair('kdfMemory', 32));
      expect(json, containsPair('kdfParallelism', 4));
      expect(json['key'], startsWith('2.'));
    });

    test('protects with PBKDF2', () async {
      final key = SymmetricCryptoKey.generate();
      final protected = await PasswordProtectedKey.protect(
        key,
        'hunter2',
        kdf: const KdfConfig.pbkdf2(iterations: 5000),
      );

      expect(protected.toJson(), isNot(contains('kdfMemory')));
      expect((await protected.open('hunter2'))!.bytes, key.bytes);
    });

    test('is read back from its JSON', () async {
      final key = SymmetricCryptoKey.generate();
      final protected = await PasswordProtectedKey.protect(
        key,
        'hunter2',
        kdf: cheapKdf,
      );
      final read = PasswordProtectedKey.fromJson(
        jsonDecode(jsonEncode(protected)) as Map<String, dynamic>,
      );

      expect((await read.open('hunter2'))!.bytes, key.bytes);
    });

    test('refuses a key derivation Bitwarden does not allow', () async {
      await expectLater(
        PasswordProtectedKey.protect(
          SymmetricCryptoKey.generate(),
          'hunter2',
          kdf: const KdfConfig.pbkdf2(iterations: 1000),
        ),
        throwsArgumentError,
      );
      final json = (await PasswordProtectedKey.protect(
        SymmetricCryptoKey.generate(),
        'hunter2',
        kdf: cheapKdf,
      )).toJson();
      expect(
        () => PasswordProtectedKey.fromJson({...json, 'kdfMemory': 1025}),
        throwsFormatException,
      );
    });

    test('refuses what is not a protected key', () {
      for (final json in [
        <String, dynamic>{},
        {'salt': '', 'key': '2.a|b|c', 'kdfType': 0, 'kdfIterations': 5000},
        {'salt': 'c2FsdA==', 'kdfType': 0, 'kdfIterations': 5000},
      ]) {
        expect(
          () => PasswordProtectedKey.fromJson(json),
          throwsFormatException,
          reason: '$json',
        );
      }
    });
  });
}
