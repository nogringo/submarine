import 'vault_command.dart';

class SyncCommand extends VaultCommand {
  SyncCommand() {
    argParser
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help:
            'Read the whole vault from every relay, then give each relay '
            'what it lacks.',
      )
      ..addFlag(
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
    await withVault(
      (session) =>
          argResults!.flag('force') ? session.reconcile() : session.sync(),
    );
    output.message('Syncing complete.');
  }
}
