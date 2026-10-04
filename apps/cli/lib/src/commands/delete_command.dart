import '../cli_exception.dart';
import 'vault_command.dart';

const _bwOnlyObjects = {'attachment', 'folder', 'org-collection'};

class DeleteCommand extends VaultCommand {
  DeleteCommand() {
    argParser.addFlag(
      'permanent',
      abbr: 'p',
      negatable: false,
      help: 'Permanently deletes the item.',
    );
  }

  @override
  final name = 'delete';

  @override
  final description =
      'Delete an object from the vault. The only object is item, which goes '
      'to the trash unless --permanent.';

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
    if (object != 'item') throw CliException('Unknown object.');

    final permanent = argResults!.flag('permanent');
    await withVault((session) async {
      final item = await session.syncedItem(id);
      if (permanent) {
        await session.vault.deleteItem(item);
      } else if (!item.cipher.isDeleted) {
        await session.vault.trashItem(item);
      }
    });
  }
}
