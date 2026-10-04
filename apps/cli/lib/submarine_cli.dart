library;

import 'package:args/command_runner.dart';

import 'src/commands/add_command.dart';
import 'src/commands/edit_command.dart';
import 'src/commands/encode_command.dart';
import 'src/commands/get_command.dart';
import 'src/commands/list_command.dart';
import 'src/commands/status_command.dart';
import 'src/commands/sync_command.dart';
import 'src/commands/vault_command.dart';

export 'src/cli_exception.dart';

class SubmarineCommandRunner extends CommandRunner<void> {
  SubmarineCommandRunner()
    : super('submarine', 'A password manager built on Nostr.') {
    argParser.addMultiOption(
      'relay',
      abbr: 'r',
      help:
          'Relay of the vault, repeat for several. Overrides the relays of '
          'the config file.',
    );
    for (final MapEntry(key: flag, value: help) in outputFlags.entries) {
      argParser.addFlag(flag, negatable: false, help: help);
    }
    addCommand(AddCommand());
    addCommand(ListCommand());
    addCommand(GetCommand());
    addCommand(EditCommand());
    addCommand(StatusCommand());
    addCommand(SyncCommand());
    addCommand(EncodeCommand());
  }
}
