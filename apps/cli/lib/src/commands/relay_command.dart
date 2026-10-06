import 'package:args/command_runner.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../relays.dart';
import 'vault_command.dart';

class RelayCommand extends Command<void> {
  RelayCommand() {
    addSubcommand(_RelayListCommand());
    addSubcommand(_RelayAddCommand());
    addSubcommand(_RelayRemoveCommand());
  }

  @override
  final name = 'relay';

  @override
  final description =
      "Show or change the vault's relay list (NIP-65). Saved locally, sent "
      'on sync.';
}

class _RelayListCommand extends VaultCommand {
  @override
  final name = 'list';

  @override
  final description = 'List the relays the vault lives on.';

  @override
  Future<void> execute() async {
    if (argResults!.rest.isNotEmpty) usageException('Expected no argument.');
    final list = await withVault((session) => session.relayList());
    output.json(relaysJson(list));
  }
}

class _RelayAddCommand extends VaultCommand {
  _RelayAddCommand() {
    argParser
      ..addFlag(
        'private',
        negatable: false,
        help: 'Encrypt the relay in the list, for the vault only to see.',
      )
      ..addFlag(
        'read',
        negatable: false,
        help:
            'Mark the relay read only. The vault reads and writes on every '
            'relay: the marker is for other clients.',
      )
      ..addFlag('write', negatable: false, help: 'Mark the relay write only.');
  }

  @override
  final name = 'add';

  @override
  final description =
      'Add a relay to the vault, or change how it is listed. A new relay gets '
      'a copy of the vault.';

  @override
  String get invocation => 'submarine relay add <url> [options]';

  @override
  Future<void> execute() async {
    final url = relayUrl(singleArgument('url'));
    final marker = switch ((
      argResults!.flag('read'),
      argResults!.flag('write'),
    )) {
      (true, false) => ReadWriteMarker.readOnly,
      (false, true) => ReadWriteMarker.writeOnly,
      _ => ReadWriteMarker.readWrite,
    };
    final private = argResults!.flag('private');
    await withVault((session) async {
      final list = await session.relayList();
      await session.vault.setRelayList(
        withRelay(list, url, marker, private: private),
      );
    });
  }
}

class _RelayRemoveCommand extends VaultCommand {
  @override
  final name = 'remove';

  @override
  final description = 'Remove a relay from the vault.';

  @override
  String get invocation => 'submarine relay remove <url>';

  @override
  Future<void> execute() async {
    final url = relayUrl(singleArgument('url'));
    await withVault((session) async {
      final list = await session.relayList();
      await session.vault.setRelayList(withoutRelay(list, url));
    });
  }
}
