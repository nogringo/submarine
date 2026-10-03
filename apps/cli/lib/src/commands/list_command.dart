import 'package:nostr_passwords/nostr_passwords.dart';

import '../cli_exception.dart';
import '../item_json.dart';
import 'vault_command.dart';

const _bwOnlyObjects = {
  'folders',
  'collections',
  'org-collections',
  'org-members',
  'organizations',
};

class ListCommand extends VaultCommand {
  ListCommand() {
    argParser
      ..addOption('search', help: 'Perform a search on the listed objects.')
      ..addFlag(
        'trash',
        negatable: false,
        help: 'Filter items that are deleted and in the trash.',
      );
  }

  @override
  final name = 'list';

  @override
  final description =
      'List an array of objects from the vault. The only object is items.';

  @override
  String get invocation => 'submarine list <object> [options]';

  @override
  Future<void> execute() async {
    final object = singleArgument('object').toLowerCase();
    if (_bwOnlyObjects.contains(object)) {
      throw CliException('Submarine does not support `list $object`.');
    }
    if (object != 'items') throw CliException('Unknown object.');

    final trash = argResults!.flag('trash');
    final search = argResults!.option('search')?.trim() ?? '';
    var items = [
      for (final item in await withVault((session) => session.items()))
        if (item.cipher.isDeleted == trash && !item.cipher.isArchived) item,
    ];
    if (search.isNotEmpty) items = searchItems(items, search);
    items.sort(
      (a, b) =>
          a.cipher.name.toLowerCase().compareTo(b.cipher.name.toLowerCase()),
    );
    output.json([for (final item in items) itemJson(item)]);
  }
}
