import 'package:nostr_passwords/nostr_passwords.dart';

import '../cli_exception.dart';
import '../find_item.dart';
import '../item_json.dart';
import 'vault_command.dart';

const _bwOnlyObjects = {
  'totp',
  'exposed',
  'attachment',
  'folder',
  'collection',
  'org-collection',
  'organization',
  'template',
  'fingerprint',
  'send',
};

class GetCommand extends VaultCommand {
  @override
  final name = 'get';

  @override
  final description =
      'Get an object from the vault: item, username, password, uri or notes.';

  @override
  String get invocation => 'submarine get <object> <id>';

  @override
  Future<void> execute() async {
    final arguments = argResults!.rest;
    if (arguments.length != 2) {
      usageException('Expected <object> and <id>, a search term or an id.');
    }
    final [object, query] = arguments;

    Future<Item> find([bool Function(Item item)? isWanted]) async => findItem(
      await withVault((session) => session.items()),
      query,
      isWanted: isWanted,
    );

    switch (object.toLowerCase()) {
      case 'item':
        output.json(itemJson(await find()));
      case 'username':
        final item = await find((item) => _isPresent(_login(item)?.username));
        output.string(_login(item)!.username);
      case 'password':
        final item = await find((item) => _isPresent(_login(item)?.password));
        output.string(_login(item)!.password);
      case 'uri':
        final item = await find(
          (item) => _isPresent(_login(item)?.uris.firstOrNull?.uri),
        );
        output.string(_login(item)!.uris.first.uri);
      case 'notes':
        final item = await find((item) => _isPresent(item.cipher.notes));
        output.string(item.cipher.notes);
      case final object when _bwOnlyObjects.contains(object):
        throw CliException('Submarine does not support `get $object`.');
      default:
        throw CliException('Unknown object.');
    }
  }
}

Login? _login(Item item) =>
    item.cipher.type == CipherType.login ? item.cipher.login : null;

bool _isPresent(String? value) => value != null && value.trim().isNotEmpty;
