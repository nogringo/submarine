import 'dart:io';

import '../settings.dart';
import 'vault_command.dart';

class StatusCommand extends VaultCommand {
  @override
  final name = 'status';

  @override
  final description =
      'Show the last sync, the vault public key, and whether the vault key '
      'is set.';

  @override
  Future<void> execute() async {
    // Like bw's status: unlocked once the key is at hand, which the
    // environment is for Submarine.
    if (!hasVaultKey(Platform.environment)) {
      output.json({'lastSync': null, 'status': 'unauthenticated'});
      return;
    }
    output.json(
      await withVault(
        (session) async => {
          'lastSync': (await session.lastSync())?.toIso8601String(),
          'userId': session.vault.signer.getPublicKey(),
          'status': 'unlocked',
        },
      ),
    );
  }
}
