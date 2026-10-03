import 'package:nostr_passwords/nostr_passwords.dart';

import 'cli_exception.dart';

/// The item `bw get` returns for [query]: the one with that id, else the only
/// search result among items neither deleted nor archived. Only the items
/// [isWanted] accepts count, which breaks a tie between several results.
Item findItem(
  Iterable<Item> items,
  String query, {
  bool Function(Item item)? isWanted,
}) {
  query = query.toLowerCase();
  final candidates = switch (items.where((item) => item.id == query)) {
    final byId when byId.isNotEmpty => byId,
    _ when query.trim().isEmpty => const <Item>[],
    _ => searchItems(
      items.where((item) => !item.cipher.isDeleted && !item.cipher.isArchived),
      query,
    ),
  };
  return switch ([...candidates.where(isWanted ?? (_) => true)]) {
    [] => throw CliException('Not found.'),
    [final item] => item,
    final several => throw CliException(
      [
        'More than one result was found. Try getting a specific object by '
            '`id` instead. The following objects were found:',
        for (final item in several) item.id,
      ].join('\n'),
    ),
  };
}
