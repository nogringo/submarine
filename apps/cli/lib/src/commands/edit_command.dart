import 'dart:io';

import 'package:nostr_passwords/nostr_passwords.dart';

import '../cli_exception.dart';
import '../item_json.dart';
import '../terminal.dart';
import '../vault_session.dart';
import 'vault_command.dart';

const _bwOnlyObjects = {'item-collections', 'folder', 'org-collection'};

class EditCommand extends VaultCommand {
  @override
  final name = 'edit';

  @override
  final description =
      'Edit an object from the vault. The only object is item. Reads the '
      'encoded JSON from stdin when left out.';

  @override
  String get invocation => 'submarine edit <object> <id> [encodedJson]';

  @override
  Future<void> execute() async {
    var (object, id, encoded) = switch (argResults!.rest) {
      [final object, final id] => (object, id, ''),
      [final object, final id, final encoded] => (object, id, encoded),
      _ => usageException(
        'Expected <object>, <id> and optionally <encodedJson>.',
      ),
    };
    object = object.toLowerCase();
    if (_bwOnlyObjects.contains(object)) {
      throw CliException('Submarine does not support `edit $object`.');
    }
    if (object != 'item') throw CliException('Unknown object.');

    if (encoded.isEmpty && !stdin.hasTerminal) encoded = await readStdin();
    if (encoded.isEmpty) throw CliException('`requestJson` was not provided.');
    final Cipher cipher;
    try {
      cipher = decodeItemJson(encoded);
    } on FormatException {
      throw CliException('Error parsing the encoded request data.');
    }

    final item = await withVault(
      (session) => _edit(session, id.toLowerCase(), cipher),
    );
    output.json(itemJson(item));
  }
}

/// Saves [cipher] over the item [id], as bw and its server would.
Future<Item> _edit(VaultSession session, String id, Cipher cipher) async {
  // Otherwise the new version could miss a head another device published.
  await session.sync();
  final item = (await session.items())
      .where((item) => item.id == id)
      .firstOrNull;
  if (item == null) throw CliException('Not found.');
  final current = item.cipher;
  if (current.isDeleted) {
    throw CliException(
      'You may not edit a deleted item. Use the restore command first.',
    );
  }
  // bw sends the revision date it read, and its server refuses a stale one.
  if ((cipher.revisionDate, current.revisionDate)
      case (final known?, final latest?)
      when latest.difference(known).abs() > const Duration(seconds: 1)) {
    throw CliException(
      'The item cannot be saved because it is out of date. To edit this '
      'item, first get it again.',
    );
  }
  // As in bw, an edit cannot change the creation date, delete or unarchive.
  cipher
    ..creationDate = current.creationDate
    ..deletedDate = null
    ..archivedDate ??= current.archivedDate;
  return Item([await session.vault.updateItem(item, cipher)]);
}
