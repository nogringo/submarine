import 'dart:io';

import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:path/path.dart' as p;
import 'package:submarine_cli/src/bitwarden_files.dart';
import 'package:submarine_cli/submarine_cli.dart';
import 'package:test/test.dart';

const clearExport =
    '{"encrypted":false,"folders":[],"items":[{"type":1,"name":"Boulanger",'
    '"login":{"username":"alice@example.com","password":"Tr0ub4dor&3"}}]}';

Matcher throwsCli(String message) => throwsA(
  isA<CliException>().having((error) => error.message, 'message', message),
);

void main() {
  group('openImport', () {
    late String protectedExport;

    setUpAll(() async {
      protectedExport = await encryptBitwardenExport(
        clearExport,
        'hunter2',
        kdf: const KdfConfig.pbkdf2(iterations: 5000),
      );
    });

    test('reads an export without asking for a password', () async {
      final [cipher] = await openImport(
        clearExport,
        () => fail('asked for a password'),
      );

      expect(cipher.name, 'Boulanger');
      expect(cipher.login!.password, 'Tr0ub4dor&3');
    });

    test('opens a password protected export with its password', () async {
      final [cipher] = await openImport(protectedExport, () => 'hunter2');

      expect(cipher.login!.username, 'alice@example.com');
    });

    test('refuses a wrong or blank password', () async {
      for (final password in ['wrong', ' ']) {
        await expectLater(
          openImport(protectedExport, () => password),
          throwsCli(
            'Invalid file password, please use the password you entered when '
            'you created the export file.',
          ),
        );
      }
    });

    test('refuses an export restricted to its Bitwarden account', () async {
      await expectLater(
        openImport('{"encrypted":true,"data":"2.x"}', () => ''),
        throwsA(isA<CliException>()),
      );
    });

    test('refuses a file that is not a Bitwarden export', () async {
      for (final source in ['not json', '[]', '{"items":[{"type":"x"}]}']) {
        await expectLater(
          openImport(source, () => ''),
          throwsCli(
            'Data is not formatted correctly. Please check your import file '
            'and try again.',
          ),
          reason: source,
        );
      }
    });

    test('refuses an export without items', () async {
      await expectLater(
        openImport('{"encrypted":false,"items":[]}', () => ''),
        throwsCli('Nothing was imported.'),
      );
    });
  });

  group('readImportFile', () {
    test('refuses a missing or empty file', () async {
      final directory = await Directory.systemTemp.createTemp('submarine');
      addTearDown(() => directory.delete(recursive: true));
      final empty = File(p.join(directory.path, 'empty.json'))..createSync();
      final missing = p.join(directory.path, 'missing.json');

      expect(
        () => readImportFile(empty.path),
        throwsCli('Import file was empty.'),
      );
      expect(
        () => readImportFile(missing),
        throwsCli('Could not read file: $missing'),
      );
    });
  });

  group('exportFormat', () {
    test('writes json by default, encrypted with a password', () {
      expect(exportFormat(null, password: false), 'json');
      expect(exportFormat(null, password: true), 'encrypted_json');
      expect(exportFormat('json', password: true), 'encrypted_json');
      expect(exportFormat('encrypted_json', password: true), 'encrypted_json');
    });

    test('needs a password for encrypted_json', () {
      expect(
        () => exportFormat('encrypted_json', password: false),
        throwsA(isA<CliException>()),
      );
    });

    test('refuses the formats Submarine does not write', () {
      expect(
        () => exportFormat('csv', password: false),
        throwsCli(
          "'csv' is not a supported export format. Supported formats: json, "
          'encrypted_json.',
        ),
      );
    });
  });

  test('exportFileName follows Bitwarden', () {
    final now = DateTime(2026, 10, 6, 9, 5, 3);

    expect(
      exportFileName(now, protected: false),
      'submarine_export_20261006090503.json',
    );
    expect(
      exportFileName(now, protected: true),
      'submarine_encrypted_export_20261006090503.json',
    );
  });

  group('exportPath', () {
    test('saves in the current directory without --output', () {
      expect(exportPath(null, 'a.json'), p.join(p.current, 'a.json'));
      expect(exportPath('b.json', 'a.json'), p.join(p.current, 'b.json'));
    });

    test('puts the file in a directory', () async {
      final directory = await Directory.systemTemp.createTemp('submarine');
      addTearDown(() => directory.delete(recursive: true));

      expect(
        exportPath('${directory.path}/new/', 'a.json'),
        p.join(directory.path, 'new', 'a.json'),
      );
      expect(
        exportPath(directory.path, 'a.json'),
        p.join(directory.path, 'a.json'),
      );
      expect(
        exportPath(p.join(directory.path, 'b.json'), 'a.json'),
        p.join(directory.path, 'b.json'),
      );
    });
  });

  test('saveExport creates the folders and keeps the file private', () async {
    final directory = await Directory.systemTemp.createTemp('submarine');
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'exports', 'vault.json');

    saveExport(path, clearExport);

    expect(File(path).readAsStringSync(), clearExport);
    if (!Platform.isWindows) {
      expect(File(path).statSync().mode & 511, 384, reason: 'mode 600');
    }
  });

  group('withBarePassword', () {
    test('gives an empty value to a bare --password', () {
      expect(withBarePassword(['export', '--password']), [
        'export',
        '--password=',
      ]);
      expect(withBarePassword(['export', '--password', '--format', 'json']), [
        'export',
        '--password=',
        '--format',
        'json',
      ]);
    });

    test('keeps a --password that has a value', () {
      expect(withBarePassword(['export', '--password', 'hunter2']), [
        'export',
        '--password',
        'hunter2',
      ]);
    });
  });

  test('a Submarine export imports back', () async {
    final item = Item([
      Envelope(
        id: 'id',
        type: 'item',
        rev: 'rev',
        parents: const [],
        modifiedAt: DateTime.utc(2026, 10, 6),
        data: Cipher(type: CipherType.secureNote, name: 'Wifi').toJson(),
      ),
    ]);

    final [cipher] = await openImport(
      writeBitwardenExport([item]),
      () => fail('asked for a password'),
    );

    expect(cipher.name, 'Wifi');
    expect(cipher.type, CipherType.secureNote);
  });
}
