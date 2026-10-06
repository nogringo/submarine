import 'package:nostr_passwords/nostr_passwords.dart';

import 'cli_exception.dart';

/// [argument] as [parseRelayUrl] reads it.
String relayUrl(String argument) =>
    parseRelayUrl(argument) ??
    (throw CliException('Not a relay URL: $argument'));

/// [list] without the relay [argument] names, even one [relayUrl] refuses,
/// such as wss://typo listed by another client.
RelayList withoutRelay(RelayList list, String argument) {
  final url = parseRelayUrl(argument) ?? argument;
  if (!list.contains(url)) throw CliException('Not found.');
  final rest = list.without(url);
  if (rest.isEmpty) throw CliException('The vault needs at least one relay.');
  return rest;
}

List<Map<String, Object>> relaysJson(RelayList list) => [
  for (final (relays, private) in [(list.public, false), (list.private, true)])
    for (final MapEntry(key: url, value: marker) in relays.entries)
      {
        'url': url,
        'read': marker.isRead,
        'write': marker.isWrite,
        'private': private,
      },
];
