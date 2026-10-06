import 'dart:io';

import '../bitwarden_files.dart';
import '../cli_exception.dart';
import '../terminal.dart';
import 'vault_command.dart';

class ImportCommand extends VaultCommand {
  ImportCommand() {
    argParser
      ..addFlag('formats', negatable: false, help: 'List formats.')
      ..addOption(
        'passwordenv',
        help: 'Environment variable storing the import file password.',
      )
      ..addOption(
        'passwordfile',
        help:
            'Path to a file containing the import file password as its first '
            'line.',
      );
  }

  @override
  final name = 'import';

  @override
  final description =
      'Import a Bitwarden JSON export into the vault, password protected or '
      'not. The only format is bitwardenjson.';

  @override
  String get invocation => 'submarine import <format> <input> [options]';

  @override
  Future<void> execute() async {
    if (argResults!.flag('formats')) {
      return output.message(
        'Supported input formats:\n$importFormat',
        rawValue: importFormat,
      );
    }
    final (format, path) = switch (argResults!.rest) {
      [] => throw CliException('`format` was not provided.'),
      [_] => throw CliException('`filepath` was not provided.'),
      [final format, final path] => (format, path),
      _ => usageException('Expected <format> and <input>.'),
    };
    if (format != importFormat) {
      throw CliException('Submarine only imports the $importFormat format.');
    }

    final ciphers = await openImport(readImportFile(path), _password);
    await withVault((session) async {
      for (final cipher in ciphers) {
        await session.vault.createItem(cipher);
      }
    });
    output.message('Imported $path');
  }

  /// From `--passwordfile`, `--passwordenv` or the user, as bw looks for it.
  String _password() {
    final file = argResults!.option('passwordfile');
    if (file != null) {
      try {
        final lines = File(file).readAsLinesSync();
        if (lines.isNotEmpty && lines.first.isNotEmpty) return lines.first;
      } on FileSystemException {
        throw CliException('Could not read file: $file');
      }
    }
    final variable = argResults!.option('passwordenv');
    if (file == null && variable != null) {
      final value = Platform.environment[variable] ?? '';
      if (value.isNotEmpty) return value;
      output.error('Warning: Provided passwordenv $variable is not set');
    }
    return promptSecret('Import file password: ');
  }
}
