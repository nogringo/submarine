import 'package:ndk/shared/helpers/relay_helper.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import 'cli_exception.dart';

/// [argument] normalized as ndk does, so that it matches the relay it names.
String relayUrl(String argument) =>
    cleanRelayUrl(argument) ??
    (throw CliException('Not a relay URL: $argument'));

/// [list] with [url], in place of the same relay with other settings.
RelayList withRelay(
  RelayList list,
  String url,
  ReadWriteMarker marker, {
  required bool private,
}) {
  final rest = _without(list, url);
  return RelayList(
    public: {...rest.public, if (!private) url: marker},
    private: {...rest.private, if (private) url: marker},
  );
}

RelayList withoutRelay(RelayList list, String url) {
  final rest = _without(list, url);
  if (_length(rest) == _length(list)) throw CliException('Not found.');
  if (_length(rest) == 0) {
    throw CliException('The vault needs at least one relay.');
  }
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

RelayList _without(RelayList list, String url) {
  bool isUrl(String relay, ReadWriteMarker _) =>
      (cleanRelayUrl(relay) ?? relay) == url;
  return RelayList(
    public: {...list.public}..removeWhere(isUrl),
    private: {...list.private}..removeWhere(isUrl),
  );
}

int _length(RelayList list) => list.public.length + list.private.length;
