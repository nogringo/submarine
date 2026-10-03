import 'dart:io';

import 'package:nostr_passwords/nostr_passwords.dart';

import '../cli_exception.dart';
import '../terminal.dart';
import 'vault_command.dart';

class AddCommand extends VaultCommand {
  AddCommand() {
    argParser
      ..addOption('uri', help: 'Website of the account.')
      ..addOption('username', abbr: 'u', help: 'Username of the account.');
  }

  @override
  final name = 'add';

  @override
  final description =
      'Save a login. Asks for what the options leave out, the password '
      'always. When stdin is piped, reads one line per question.';

  @override
  String get invocation => 'submarine add <name> [options]';

  @override
  Future<void> run() async {
    final itemName = singleArgument('name');
    final uri = argResults!.option('uri') ?? prompt('URI (optional): ');
    final username = argResults!.option('username') ?? prompt('Username: ');
    final password = promptSecret('Password: ');
    if (password.isEmpty) throw CliException('The password cannot be empty.');

    final cipher = Cipher(
      type: CipherType.login,
      name: itemName,
      login: Login(
        uris: [if (uri.isNotEmpty) LoginUri(uri)],
        username: username.isEmpty ? null : username,
        password: password,
      ),
    );
    try {
      await withVault((session) => session.vault.createItem(cipher));
    } on PublishException catch (error) {
      throw CliException(
        [
          'No relay accepted $itemName:',
          for (final MapEntry(:key, :value) in error.relayMessages.entries)
            '  $key: $value',
        ].join('\n'),
      );
    }
    stdout.writeln('Saved $itemName.');
  }
}
