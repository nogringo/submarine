import 'dart:convert';

import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

/// The password and salt of the KDF test vectors of Bitwarden's SDK, in
/// bitwarden-crypto/src/keys/kdf.rs. The exports below were encrypted with
/// the keys of these vectors, stretched, by OpenSSL.
const password = r'67t9b5g67$%Dh89n';

const clearExport =
    '{"encrypted":false,"folders":[],"items":[{"type":1,"name":"Boulanger",'
    '"login":{"username":"alice@example.com","password":"Tr0ub4dor&3"}}]}';

const pbkdf2Export =
    '{"encrypted": true, "passwordProtected": true, "salt": "test_key", '
    '"kdfType": 0, "kdfIterations": 10000, "encKeyValidation_DO_NOT_EDIT": '
    '"2.AAECAwQFBgcICQoLDA0ODw==|em3TVNwuBT49+IT3PH+UivF99LjypWQhW6ldAZ0wjXs8'
    'FeiW8CzDGsvKACcKOuKd|T7LOHqJw+J31XWyGyo2pVnz2JiHuJJj/+Y2IpQ4fy/w=", '
    '"data": "2.EBESExQVFhcYGRobHB0eHw==|ahtFunTNZrcV38nl5E1aiC5k0MkpLD9Zj38v'
    'RVPazFBTV98XpvdpXag6XBRdTbjIYIcS2siOGwoawmqtarwWlk9wLjCHh7YqiSrh/wMeHOSU'
    'pRxOtcrH4Sm/tsxbg2uaXzTnY7KeuR3Q+nNLec6xxhyc62m3YCBF9C3CFY8MJYIyZR8IbIKQ'
    'J46PurECTlVl|ziJEWeK0JBHn29zd4SLS0VSbh58x1WxZ0msqiyfx3J8="}';

const argon2idExport =
    '{"encrypted": true, "passwordProtected": true, "salt": "test_key", '
    '"kdfType": 1, "kdfIterations": 4, "kdfMemory": 32, "kdfParallelism": 2, '
    '"encKeyValidation_DO_NOT_EDIT": "2.AAECAwQFBgcICQoLDA0ODw==|wd51UmmlZuhR'
    'RQsyXxJCzOvGWxbwXuSehuPQn97oZo2VHn50ywNbv6EJSkMCb2um|2yA4P20bOwZ+puU0i28D'
    '71RgKblPusqASHmRCXORp0Q=", "data": "2.EBESExQVFhcYGRobHB0eHw==|cEzT2CpIxLB'
    'g96VLAv565MK+svA0TLcmbA+BdVro5I9kkJhNz5avDD3LdNZhfoZyWqjBn5CLQnPmBJO3KpMP'
    '1Fd9pggI5x0GPFC7hh2hFY23x0lQbGbGOX4KD/rPBCX7tRnHvp5UJBhAUg7AvoQOnp3gMYRw'
    'zNyR/EwPUyY+KKzwceb8UlSL/vHfUdNstwNd|/uv/u47cd/jj+Oi0n0qtJPH4bg55gvmV1OUL'
    'dGgRveE="}';

Item item(String id, Cipher cipher) => Item([
  Envelope(
    id: id,
    type: 'item',
    rev: 'rev-$id',
    parents: const [],
    modifiedAt: DateTime.utc(2026, 10, 5),
    data: cipher.toJson(),
  ),
]);

void main() {
  group('parseBitwardenExport', () {
    test('reads an individual export as Bitwarden imports it', () {
      final ciphers = parseBitwardenExport(
        jsonEncode({
          'encrypted': false,
          'folders': [
            {'id': 'f1', 'name': 'Shopping'},
          ],
          'items': [
            {
              'passwordHistory': [
                for (var i = 6; i > 0; i--)
                  {
                    'lastUsedDate': '2026-09-0${i}T10:00:00.000Z',
                    'password': 'old $i',
                  },
              ],
              'revisionDate': '2026-09-30T10:00:00.000Z',
              'creationDate': '2025-03-02T10:00:00.000Z',
              'deletedDate': null,
              'archivedDate': null,
              'id': 'bitwarden-id',
              'organizationId': null,
              'folderId': 'f1',
              'type': 1,
              'reprompt': 0,
              'name': 'Boulanger',
              'notes': null,
              'favorite': true,
              'login': {
                'uris': [
                  {'match': null, 'uri': 'https://www.boulanger.com'},
                ],
                'fido2Credentials': [],
                'username': 'alice@example.com',
                'password': 'Tr0ub4dor&3',
                'totp': null,
              },
              'collectionIds': null,
              'key': '2.encrypted|cipher|key',
            },
          ],
        }),
      );

      final [cipher] = ciphers;
      final json = cipher.toJson();
      for (final key in ['id', 'organizationId', 'collectionIds', 'key']) {
        expect(json, isNot(contains(key)));
      }
      expect(json['folderId'], isNull);
      expect(cipher.name, 'Boulanger');
      expect(cipher.favorite, isTrue);
      expect(cipher.login?.password, 'Tr0ub4dor&3');
      expect(cipher.login?.uris.single.uri, 'https://www.boulanger.com');
      expect(
        [for (final entry in cipher.passwordHistory) entry.password],
        ['old 6', 'old 5', 'old 4', 'old 3', 'old 2'],
      );
      expect(cipher.creationDate, DateTime.utc(2025, 3, 2, 10));
      expect(cipher.revisionDate, DateTime.utc(2026, 9, 30, 10));
    });

    test('cleans items up as Bitwarden does', () {
      final [note, unnamed] = parseBitwardenExport(
        jsonEncode({
          'encrypted': false,
          'items': [
            {
              'type': 2,
              'name': 'Alarm code',
              'notes': '1234',
              'secureNote': {'type': 0},
              'login': {'username': 'left over'},
            },
            {'type': 1, 'name': '  ', 'notes': ' \n '},
          ],
        }),
      );

      expect(note.login, isNull);
      expect(note.secureNote, isNotNull);
      expect(note.creationDate, isNotNull);
      expect(note.revisionDate, note.creationDate);
      expect(unnamed.name, '--');
      expect(unnamed.notes, isNull);
    });

    test('reads an organization export, without its collections', () {
      final [cipher] = parseBitwardenExport(
        jsonEncode({
          'encrypted': false,
          'collections': [
            {'id': 'c1', 'organizationId': 'o1', 'name': 'Family'},
          ],
          'items': [
            {
              'id': 'bitwarden-id',
              'organizationId': 'o1',
              'collectionIds': ['c1'],
              'type': 1,
              'name': 'Freebox',
              'login': {'username': 'freebox'},
            },
          ],
        }),
      );

      expect(cipher.toJson(), isNot(contains('organizationId')));
      expect(cipher.toJson(), isNot(contains('collectionIds')));
      expect(cipher.login?.username, 'freebox');
    });

    test('skips a byte order mark', () {
      expect(
        parseBitwardenExport('\uFEFF{"encrypted":false,"items":[]}'),
        isEmpty,
      );
    });

    test('refuses an export restricted to its account', () {
      expect(
        () => parseBitwardenExport(
          jsonEncode({
            'encrypted': true,
            'encKeyValidation_DO_NOT_EDIT': '2.abc|def|ghi',
            'folders': [],
            'items': [],
          }),
        ),
        throwsA(isA<EncryptedExportException>()),
      );
    });

    test('leaves a password protected export to decryptBitwardenExport', () {
      expect(
        () => parseBitwardenExport(pbkdf2Export),
        throwsA(isA<PasswordProtectedExportException>()),
      );
    });

    test('refuses what is not a Bitwarden JSON export', () {
      for (final source in [
        'name,login_uri,login_username,login_password',
        '[]',
        '{"encrypted":false}',
        '{"items":[1]}',
        '{"items":[{"type":"login","name":"GitHub"}]}',
      ]) {
        expect(
          () => parseBitwardenExport(source),
          throwsFormatException,
          reason: source,
        );
      }
    });
  });

  group('writeBitwardenExport', () {
    final github = Cipher(
      type: CipherType.login,
      name: 'GitHub',
      login: Login(
        uris: [LoginUri('https://github.com')],
        username: 'alice-dev',
        password: 'Tr0ub4dor&3',
      ),
    );

    test('writes the individual export of Bitwarden, without the trash', () {
      final export = jsonDecode(
        writeBitwardenExport([
          item('a1', github),
          item(
            'a2',
            Cipher(
              type: CipherType.secureNote,
              name: 'Old note',
              deletedDate: DateTime.utc(2026, 10, 1),
            ),
          ),
        ]),
      ) as Map<String, dynamic>;

      expect(export['encrypted'], isFalse);
      expect(export['folders'], isEmpty);
      final [exported] = export['items'] as List;
      expect(exported, {
        'id': 'a1',
        'organizationId': null,
        'folderId': null,
        'collectionIds': null,
        ...github.toJson(),
      });
    });

    test('writes the ids of the item, never those of an account', () {
      final cipher = Cipher.fromJson({
        ...github.toJson(),
        'id': 'bitwarden-id',
        'organizationId': 'o1',
        'folderId': 'f1',
        'collectionIds': ['c1'],
        'key': '2.encrypted|cipher|key',
      });

      final [exported] =
          (jsonDecode(writeBitwardenExport([item('a1', cipher)]))
                  as Map<String, dynamic>)['items']
              as List;

      expect(exported, containsPair('id', 'a1'));
      expect(exported, containsPair('organizationId', null));
      expect(exported, containsPair('folderId', null));
      expect(exported, containsPair('collectionIds', null));
      expect(exported, isNot(contains('key')));
    });

    test('is read back as it was written', () {
      final [cipher] = parseBitwardenExport(
        writeBitwardenExport([item('a1', github)]),
      );

      expect(cipher.toJson(), github.toJson());
    });
  });

  group('decryptBitwardenExport', () {
    test('opens an export protected with PBKDF2 as Bitwarden does', () async {
      expect(await decryptBitwardenExport(pbkdf2Export, password), clearExport);
    });

    test('opens an export protected with Argon2id as Bitwarden does', () async {
      expect(
        await decryptBitwardenExport(argon2idExport, password),
        clearExport,
      );
    });

    test('refuses a wrong password', () async {
      for (final wrong in ['', '67t9b5g67\$%Dh89N']) {
        await expectLater(
          decryptBitwardenExport(pbkdf2Export, wrong),
          throwsA(isA<WrongExportPasswordException>()),
        );
      }
    });

    test('refuses a damaged export', () async {
      final export = jsonDecode(pbkdf2Export) as Map<String, dynamic>;
      final data = export['data'] as String;
      await expectLater(
        decryptBitwardenExport(
          jsonEncode({...export, 'data': data.replaceFirst('|ah', '|AH')}),
          password,
        ),
        throwsFormatException,
      );
    });

    test('refuses a key derivation Bitwarden does not allow', () async {
      final export = jsonDecode(argon2idExport) as Map<String, dynamic>;
      for (final kdf in [
        {'kdfType': 0, 'kdfIterations': 4999},
        {'kdfType': 1, 'kdfMemory': 1025},
        {'kdfType': 1, 'kdfMemory': null},
        {'kdfType': 2},
      ]) {
        await expectLater(
          decryptBitwardenExport(jsonEncode({...export, ...kdf}), password),
          throwsFormatException,
          reason: '$kdf',
        );
      }
    });

    test('refuses an export that is not password protected', () async {
      await expectLater(
        decryptBitwardenExport(clearExport, password),
        throwsFormatException,
      );
    });
  });

  group('encryptBitwardenExport', () {
    test('protects an export with Argon2id, Bitwarden defaults', () async {
      final protected = await encryptBitwardenExport(clearExport, 'hunter2');
      final export = jsonDecode(protected) as Map<String, dynamic>;

      expect(export, containsPair('encrypted', true));
      expect(export, containsPair('passwordProtected', true));
      expect(base64.decode(export['salt'] as String), hasLength(16));
      expect(export, containsPair('kdfType', 1));
      expect(export, containsPair('kdfIterations', 6));
      expect(export, containsPair('kdfMemory', 32));
      expect(export, containsPair('kdfParallelism', 4));
      expect(export['encKeyValidation_DO_NOT_EDIT'], startsWith('2.'));
      expect(export['data'], startsWith('2.'));
      expect(await decryptBitwardenExport(protected, 'hunter2'), clearExport);
    });

    test('protects an export with PBKDF2', () async {
      final protected = await encryptBitwardenExport(
        clearExport,
        'hunter2',
        kdf: const ExportKdf.pbkdf2(iterations: 5000),
      );
      final export = jsonDecode(protected) as Map<String, dynamic>;

      expect(export, containsPair('kdfType', 0));
      expect(export, containsPair('kdfIterations', 5000));
      expect(export, isNot(contains('kdfMemory')));
      expect(export, isNot(contains('kdfParallelism')));
      expect(await decryptBitwardenExport(protected, 'hunter2'), clearExport);
    });

    test('refuses a key derivation Bitwarden does not allow', () async {
      await expectLater(
        encryptBitwardenExport(
          clearExport,
          'hunter2',
          kdf: const ExportKdf.pbkdf2(iterations: 1000),
        ),
        throwsArgumentError,
      );
    });
  });
}
