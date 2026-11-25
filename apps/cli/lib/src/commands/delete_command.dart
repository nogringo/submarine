import 'package:ndk/ndk.dart';

import '../cli_exception.dart';
import 'vault_command.dart';

const _bwOnlyObjects = {'attachment', 'folder', 'org-collection'};

class DeleteCommand extends VaultCommand {
  DeleteCommand() {
    argParser
      ..addFlag(
        'permanent',
        abbr: 'p',
        negatable: false,
        help: 'Permanently deletes the item.',
      )
      ..addFlag(
        'mailboxes',
        negatable: false,
        help:
            'With vault, also deletes the email addresses of its items, and '
            'their messages.',
      );
  }

  @override
  final name = 'delete';

  @override
  final description =
      'Delete an object: an item, which goes to the trash unless '
      '--permanent, or the vault, for good, whose <id> is its public key.';

  @override
  String get invocation => 'submarine delete <object> <id> [options]';

  @override
  Future<void> execute() async {
    final (object, id) = switch (argResults!.rest) {
      [final object, final id] => (object.toLowerCase(), id.toLowerCase()),
      _ => usageException('Expected <object> and <id>.'),
    };
    if (_bwOnlyObjects.contains(object)) {
      throw CliException('Submarine does not support `delete $object`.');
    }
    final withMailboxes = argResults!.flag('mailboxes');
    if (object == 'vault') return _deleteVault(id, withMailboxes);
    if (object != 'item') throw CliException('Unknown object.');
    if (withMailboxes) usageException('--mailboxes goes with vault only.');

    final permanent = argResults!.flag('permanent');
    await withVault((session) async {
      final item = await session.item(id);
      if (permanent) {
        await session.vault.deleteItem(item);
      } else if (!item.cipher.isDeleted) {
        await session.vault.trashItem(item);
      }
    });
  }

  Future<void> _deleteVault(String id, bool withMailboxes) =>
      withVault((session) async {
        final pubkey = session.vault.signer.getPublicKey();
        if (id != pubkey && id != Nip19.encodePubKey(pubkey)) {
          throw CliException(
            'Not this vault: give its public key, the userId of `status`.',
          );
        }
        await session.delete(withMailboxes: withMailboxes);
      });
}
