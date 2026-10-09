import 'package:ndk/domain_layer/entities/nip_65.dart';
import 'package:ndk/domain_layer/entities/read_write_marker.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/helpers/relay_helper.dart';

import 'private_tags.dart';

export 'package:ndk/domain_layer/entities/read_write_marker.dart';

/// A vault's relays, in a NIP-65 relay list: the public ones in the tags, the
/// private ones encrypted to the vault in the content, as NIP-51 does for
/// private items.
///
/// The vault reads and writes on every relay: it keeps their marker for other
/// clients only.
class RelayList {
  const RelayList({this.public = const {}, this.private = const {}});

  final Map<String, ReadWriteMarker> public;
  final Map<String, ReadWriteMarker> private;

  /// Every relay, the public ones first.
  Set<String> get urls => {...public.keys, ...private.keys};

  bool get isEmpty => public.isEmpty && private.isEmpty;

  /// Whether [url] is listed, both normalized as ndk does.
  bool contains(String url) =>
      urls.any((relay) => _normalized(relay) == _normalized(url));

  /// This list with [url], as [parseRelayUrl] reads it, in place of the same
  /// relay with other settings.
  RelayList withRelay(
    String url, {
    ReadWriteMarker marker = ReadWriteMarker.readWrite,
    bool private = false,
  }) {
    final relay =
        parseRelayUrl(url) ??
        (throw ArgumentError.value(url, 'url', 'Not a relay URL'));
    final rest = without(relay);
    return RelayList(
      public: {...rest.public, if (!private) relay: marker},
      private: {...rest.private, if (private) relay: marker},
    );
  }

  RelayList without(String url) {
    bool isUrl(String relay, ReadWriteMarker _) =>
        _normalized(relay) == _normalized(url);
    return RelayList(
      public: {...public}..removeWhere(isUrl),
      private: {...private}..removeWhere(isUrl),
    );
  }

  static String _normalized(String url) => cleanRelayUrl(url) ?? url;
}

/// A relay address as a user types it, wss:// when it has no scheme,
/// normalized as ndk does. Returns null for anything else, a host without a
/// dot included, localhost aside: ndk takes "wss://typo" for a relay.
String? parseRelayUrl(String text) {
  final trimmed = text.trim();
  final url = cleanRelayUrl(
    trimmed.contains('://') ? trimmed : 'wss://$trimmed',
  );
  if (url == null) return null;
  final host = Uri.parse(url).host;
  return host.contains('.') || host == 'localhost' ? url : null;
}

/// [createdAt] is now by default.
Future<Nip01Event> signRelayList(
  RelayList list,
  EventSigner vault, {
  int? createdAt,
}) async => vault.sign(
  Nip01Event(
    pubKey: vault.getPublicKey(),
    kind: Nip65.kKind,
    tags: _tags(list.public),
    content: await encryptPrivateTags(_tags(list.private), vault),
    createdAt: createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
  ),
);

Future<RelayList> readRelayList(Nip01Event event, EventSigner vault) async {
  if (event.kind != Nip65.kKind || event.pubKey != vault.getPublicKey()) {
    throw FormatException('Event ${event.id} is not a relay list of the vault');
  }
  return RelayList(
    public: _relays(event.tags),
    private: _relays(await decryptPrivateTags(event, vault)),
  );
}

List<List<String>> _tags(Map<String, ReadWriteMarker> relays) => [
  for (final MapEntry(key: relay, value: marker) in relays.entries)
    switch (marker) {
      ReadWriteMarker.readOnly => ['r', relay, 'read'],
      ReadWriteMarker.writeOnly => ['r', relay, 'write'],
      ReadWriteMarker.readWrite => ['r', relay],
    },
];

Map<String, ReadWriteMarker> _relays(List<dynamic> tags) => {
  for (final tag in tags)
    if (tag case ['r', final String relay, ...final marker])
      relay: switch (marker) {
        ['read', ...] => ReadWriteMarker.readOnly,
        ['write', ...] => ReadWriteMarker.writeOnly,
        _ => ReadWriteMarker.readWrite,
      },
};
