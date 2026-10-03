import 'vault_command.dart';

class SyncCommand extends VaultCommand {
  SyncCommand() {
    argParser.addFlag(
      'last',
      negatable: false,
      help: 'Print the date of the last sync instead of syncing.',
    );
  }

  @override
  final name = 'sync';

  @override
  final description =
      'Fetch from the relays what changed in the vault since the last sync.';

  @override
  Future<void> execute() async {
    if (argResults!.flag('last')) {
      final lastSync = await withVault((session) => session.lastSync());
      output.string(lastSync?.toIso8601String());
      return;
    }
    await withVault((session) => session.sync());
    output.message('Syncing complete.');
  }
}
