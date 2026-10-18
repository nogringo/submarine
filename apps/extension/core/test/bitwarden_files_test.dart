import 'dart:convert';

import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:submarine_extension_core/bitwarden_files.dart';
import 'package:submarine_extension_core/core.dart';
import 'package:test/test.dart';

void main() {
  final export = jsonEncode({
    'encrypted': false,
    'items': [
      {
        'id': 'bitwarden-id',
        'type': 1,
        'name': 'GitHub',
        'login': {'username': 'alice', 'password': 'hunter2'},
      },
    ],
  });

  Matcher failsWith(String code) =>
      throwsA(isA<CoreException>().having((e) => e.code, 'code', code));

  test('reads the items of an export in Bitwarden\'s JSON', () async {
    final ciphers = await openExport(export, null);

    expect(ciphers, [
      allOf(
        containsPair('name', 'GitHub'),
        containsPair('login', containsPair('password', 'hunter2')),
        isNot(contains('id')),
      ),
    ]);
  });

  test('opens a password protected export with its password', () async {
    final protected = await encryptBitwardenExport(
      export,
      'pw',
      kdf: const KdfConfig.pbkdf2(iterations: 5000),
    );

    await expectLater(
      openExport(protected, null),
      failsWith('passwordProtectedExport'),
    );
    await expectLater(
      openExport(protected, 'wrong'),
      failsWith('wrongExportPassword'),
    );
    expect(await openExport(protected, 'pw'), [containsPair('name', 'GitHub')]);
  });

  test('tells an export restricted to its account', () async {
    await expectLater(
      openExport(jsonEncode({'encrypted': true, 'items': []}), null),
      failsWith('encryptedExport'),
    );
  });

  test('tells a file that is not an export', () async {
    await expectLater(
      openExport('{"a": 1}', null),
      failsWith('notBitwardenExport'),
    );
    await expectLater(
      openExport('not json', null),
      failsWith('notBitwardenExport'),
    );
  });
}
