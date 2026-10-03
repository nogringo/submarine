import 'dart:io';

import '../cli_exception.dart';
import 'list_command.dart';
import 'vault_command.dart';

class GetCommand extends VaultCommand {
  @override
  final name = 'get';

  @override
  final description =
      'Show the username and password of an item, found by name or by id.';

  @override
  String get invocation => 'submarine get <name>';

  @override
  Future<void> run() async {
    final query = singleArgument('name');
    final items = await withVault((session) => session.items());
    final matches = [
      for (final item in items)
        if (item.id == query ||
            item.cipher.name.toLowerCase() == query.toLowerCase())
          item,
    ];

    switch (matches) {
      case []:
        throw CliException('No item named "$query".');
      case [final item]:
        final login = item.cipher.login;
        if (login?.username case final username?) {
          stdout.writeln('Username: $username');
        }
        if (login?.password case final password?) {
          stdout.writeln('Password: $password');
        }
        for (final uri in login?.uris ?? const []) {
          if (uri.uri case final uri?) stdout.writeln('URI: $uri');
        }
      default:
        throw CliException(
          [
            'Several items are named "$query", get one by id:',
            for (final item in matches) '  ${item.id}  ${describe(item)}',
          ].join('\n'),
        );
    }
  }
}
