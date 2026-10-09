import 'package:args/command_runner.dart';

import '../servers.dart';
import 'vault_command.dart';

class ServerCommand extends Command<void> {
  ServerCommand() {
    addSubcommand(_ServerListCommand());
    addSubcommand(_ServerAddCommand());
    addSubcommand(_ServerRemoveCommand());
  }

  @override
  final name = 'server';

  @override
  final description =
      "Show or change the vault's Blossom servers (BUD-03). Saved locally, "
      'sent on sync.';
}

class _ServerListCommand extends VaultCommand {
  @override
  final name = 'list';

  @override
  final description = 'List the servers the vault keeps its files on.';

  @override
  Future<void> execute() async {
    if (argResults!.rest.isNotEmpty) usageException('Expected no argument.');
    final list = await withVault((session) => session.serverList());
    output.json(serversJson(list));
  }
}

class _ServerAddCommand extends VaultCommand {
  _ServerAddCommand() {
    argParser.addFlag(
      'private',
      negatable: false,
      help: 'Encrypt the server in the list, for the vault only to see.',
    );
  }

  @override
  final name = 'add';

  @override
  final description = 'Add a server to the vault, or change how it is listed.';

  @override
  String get invocation => 'submarine server add <url> [options]';

  @override
  Future<void> execute() async {
    final url = serverUrl(singleArgument('url'));
    final private = argResults!.flag('private');
    await withVault((session) async {
      final list = await session.serverList();
      await session.vault.setServerList(list.withServer(url, private: private));
    });
  }
}

class _ServerRemoveCommand extends VaultCommand {
  @override
  final name = 'remove';

  @override
  final description = 'Remove a server from the vault.';

  @override
  String get invocation => 'submarine server remove <url>';

  @override
  Future<void> execute() async {
    final argument = singleArgument('url');
    await withVault((session) async {
      final list = await session.serverList();
      await session.vault.setServerList(withoutServer(list, argument));
    });
  }
}
