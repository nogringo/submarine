import 'dart:convert';
import 'dart:io';

import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:path/path.dart' as p;

import 'cli_exception.dart';

/// The only format `import` reads, which covers password protected exports.
const importFormat = 'bitwardenjson';

const exportFormats = ['json', 'encrypted_json'];

/// The contents of the file `import` reads. Fails with bw's messages.
String readImportFile(String path) {
  final String source;
  try {
    source = utf8.decode(File(path).readAsBytesSync(), allowMalformed: true);
  } on FileSystemException {
    throw CliException('Could not read file: $path');
  }
  if (source.isEmpty) throw CliException('Import file was empty.');
  return source;
}

/// The items of the Bitwarden JSON export [source], asking for its [password]
/// when it is password protected. Fails with bw's messages.
Future<List<Cipher>> openImport(
  String source,
  String Function() password,
) async {
  try {
    final ciphers = await _openExport(source, password);
    if (ciphers.isEmpty) throw CliException('Nothing was imported.');
    return ciphers;
  } on WrongExportPasswordException {
    throw CliException(
      'Invalid file password, please use the password you entered when you '
      'created the export file.',
    );
  } on EncryptedExportException {
    throw CliException(
      'The export is restricted to its Bitwarden account. Export the vault '
      'from Bitwarden again, password protected or in the json format.',
    );
  } on FormatException {
    throw CliException(
      'Data is not formatted correctly. Please check your import file and try '
      'again.',
    );
  }
}

Future<List<Cipher>> _openExport(
  String source,
  String Function() password,
) async {
  try {
    return parseBitwardenExport(source);
  } on PasswordProtectedExportException {
    final given = password();
    if (given.trim().isEmpty) throw const WrongExportPasswordException();
    return parseBitwardenExport(await decryptBitwardenExport(source, given));
  }
}

/// The format `export` writes for `--format` [format], as bw resolves it
/// with `--password`, except that the default is json instead of csv.
String exportFormat(String? format, {required bool password}) {
  final resolved = password && (format ?? 'json') == 'json'
      ? 'encrypted_json'
      : format ?? 'json';
  if (!exportFormats.contains(resolved)) {
    throw CliException(
      "'$resolved' is not a supported export format. Supported formats: "
      '${exportFormats.join(', ')}.',
    );
  }
  if (resolved == 'encrypted_json' && !password) {
    // bw would encrypt with the account key.
    throw CliException(
      'encrypted_json needs --password: a vault has no account key.',
    );
  }
  return resolved;
}

/// As Bitwarden names its exports, and as the app does.
String exportFileName(DateTime now, {required bool protected}) {
  String two(int value) => '$value'.padLeft(2, '0');
  final date =
      '${now.year}${two(now.month)}${two(now.day)}'
      '${two(now.hour)}${two(now.minute)}${two(now.second)}';
  return 'submarine_${protected ? 'encrypted_' : ''}export_$date.json';
}

/// Where `export` saves [fileName] for `--output` [output], as bw decides,
/// except that an existing directory gets the file instead of failing.
String exportPath(String? output, String fileName) {
  if (output == null || output.isEmpty) return p.absolute(fileName);
  final directory =
      output.endsWith('/') ||
      output.endsWith(p.separator) ||
      FileSystemEntity.isDirectorySync(output);
  return p.normalize(p.absolute(directory ? p.join(output, fileName) : output));
}

/// Writes [content] to [path], creating its folders, readable by its owner
/// only as bw does.
void saveExport(String path, String content) {
  try {
    final file = File(path)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('');
    // Before the content lands: an export holds the passwords.
    if (!Platform.isWindows &&
        Process.runSync('chmod', ['600', path]).exitCode != 0) {
      throw FileSystemException('chmod failed', path);
    }
    file.writeAsStringSync(content);
  } on FileSystemException {
    throw CliException('Cannot save file to $path');
  }
}
