library;

import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'src/commands/add_command.dart';
import 'src/commands/create_command.dart';
import 'src/commands/delete_command.dart';
import 'src/commands/edit_command.dart';
import 'src/commands/encode_command.dart';
import 'src/commands/export_command.dart';
import 'src/commands/generate_command.dart';
import 'src/commands/get_command.dart';
import 'src/commands/import_command.dart';
import 'src/commands/list_command.dart';
import 'src/commands/relay_command.dart';
import 'src/commands/server_command.dart';
import 'src/commands/restore_command.dart';
import 'src/commands/status_command.dart';
import 'src/commands/sync_command.dart';
import 'src/commands/vault_command.dart';
import 'src/version.dart';

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
    argParser.addFlag('version', negatable: false, help: 'Print the version.');
    addCommand(AddCommand());
    addCommand(ListCommand());
    addCommand(GetCommand());
    addCommand(CreateCommand());
    addCommand(EditCommand());
    addCommand(DeleteCommand());
    addCommand(RestoreCommand());
    addCommand(ImportCommand());
    addCommand(ExportCommand());
    addCommand(RelayCommand());
    addCommand(ServerCommand());
    addCommand(StatusCommand());
    addCommand(SyncCommand());
    addCommand(GenerateCommand());
    addCommand(EncodeCommand());
  }

  @override
  ArgResults parse(Iterable<String> args) =>
      super.parse(withBarePassword(args.toList()));

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.flag('version')) {
      stdout.writeln(packageVersion);
      return;
    }
    await super.runCommand(topLevelResults);
  }
}

/// bw's `export --password [password]`: args has no option with an optional
/// value, so a bare `--password` becomes an empty one, which asks for it.
List<String> withBarePassword(List<String> args) => [
  for (final (index, arg) in args.indexed)
    if (arg == '--password' &&
        (index == args.length - 1 || args[index + 1].startsWith('-')))
      '--password='
    else
      arg,
];
