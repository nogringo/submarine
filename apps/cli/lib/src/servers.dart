import 'package:nostr_passwords/nostr_passwords.dart';

import 'cli_exception.dart';

/// [argument] as [parseServerUrl] reads it.
String serverUrl(String argument) =>
    parseServerUrl(argument) ??
    (throw CliException('Not a server URL: $argument'));

/// [list] without the server [argument] names, even one [serverUrl] refuses,
/// such as https://typo listed by another client.
ServerList withoutServer(ServerList list, String argument) {
  if (!list.contains(argument)) throw CliException('Not found.');
  final rest = list.without(argument);
  if (rest.isEmpty) throw CliException('The vault needs at least one server.');
  return rest;
}

List<Map<String, Object>> serversJson(ServerList list) => [
  for (final (servers, private) in [(list.public, false), (list.private, true)])
    for (final url in servers) {'url': url, 'private': private},
];
