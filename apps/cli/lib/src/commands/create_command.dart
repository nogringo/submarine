import 'package:nostr_passwords/nostr_passwords.dart';

import '../cli_exception.dart';
import '../item_json.dart';
import 'vault_command.dart';

const _bwOnlyObjects = {'attachment', 'folder', 'org-collection'};

class CreateCommand extends VaultCommand {
  @override
  final name = 'create';

  @override
  final description =
      'Create an object in the vault. The only object is item. Reads the '
      'encoded JSON from stdin when left out.';

  @override
  String get invocation => 'submarine create <object> [encodedJson]';

  @override
  Future<void> execute() async {
    final (object, encoded) = switch (argResults!.rest) {
      [final object] => (object.toLowerCase(), ''),
      [final object, final encoded] => (object.toLowerCase(), encoded),
      _ => usageException('Expected <object> and optionally <encodedJson>.'),
    };
    if (_bwOnlyObjects.contains(object)) {
      throw CliException('Submarine does not support `create $object`.');
    }
    if (object != 'item') throw CliException('Unknown object.');

    final now = DateTime.now().toUtc();
    // As bw's server does: a new item starts now, out of the trash and the
    // archive.
    final cipher = (await readItemRequest(encoded))
      ..creationDate = now
      ..revisionDate = now
      ..deletedDate = null
      ..archivedDate = null;
    final envelope = await withVault(
      (session) => session.vault.createItem(cipher),
    );
    output.json(itemJson(Item([envelope])));
  }
}
