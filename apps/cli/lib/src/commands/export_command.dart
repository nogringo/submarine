import 'package:nostr_passwords/nostr_passwords.dart';

import '../bitwarden_files.dart';
import '../cli_exception.dart';
import '../terminal.dart';
import 'vault_command.dart';

class ExportCommand extends VaultCommand {
  ExportCommand() {
    argParser
      ..addOption('output', help: 'Output directory or filename.')
      ..addOption(
        'format',
        help: 'Export file format: json (default) or encrypted_json.',
      )
      ..addOption(
        'password',
        help:
            'Protect the file with this password, asked for when left out. '
            'Turns json into encrypted_json.',
      );
  }

  @override
  final name = 'export';

  @override
  final description =
      'Export the vault to a Bitwarden JSON file, password protected or not. '
      'With --raw and no --output, prints the file instead.';

  @override
  String get invocation => 'submarine export [options]';

  @override
  Future<void> execute() async {
    final password = argResults!.option('password');
    final protected =
        exportFormat(
          argResults!.option('format'),
          password: password != null,
        ) ==
        'encrypted_json';

    final export = writeBitwardenExport(
      await withVault((session) => session.items()),
    );
    final content = protected
        ? await encryptBitwardenExport(export, _password(password!))
        : export;

    final destination = argResults!.option('output');
    if ((destination == null || destination.isEmpty) && output.raw) {
      return output.string(content);
    }
    final path = exportPath(
      destination,
      exportFileName(DateTime.now(), protected: protected),
    );
    saveExport(path, content);
    output.message('Saved $path', rawValue: path);
  }

  String _password(String given) {
    final password = given.isEmpty
        ? promptSecret('Export file password: ')
        : given;
    if (password.isEmpty) throw CliException('The password cannot be empty.');
    return password;
  }
}
