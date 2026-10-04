import '../cli_exception.dart';
import 'vault_command.dart';

class RestoreCommand extends VaultCommand {
  @override
  final name = 'restore';

  @override
  final description =
      'Restore an object from the trash. The only object is item.';

  @override
  String get invocation => 'submarine restore <object> <id>';

  @override
  Future<void> execute() async {
    final (object, id) = switch (argResults!.rest) {
      [final object, final id] => (object.toLowerCase(), id.toLowerCase()),
      _ => usageException('Expected <object> and <id>.'),
    };
    if (object != 'item') throw CliException('Unknown object.');

    await withVault((session) async {
      final item = await session.item(id);
      if (!item.cipher.isDeleted) {
        throw CliException('Cipher is not in trash.');
      }
      await session.vault.restoreItem(item);
    });
  }
}
